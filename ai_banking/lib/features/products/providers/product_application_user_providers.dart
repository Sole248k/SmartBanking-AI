import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/failure.dart';
import '../../admin/domain/product_application.dart';

part 'product_application_user_providers.g.dart';

class UserProductApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  static const String _collection = 'product_applications';

  /// Submit a new product application for admin review.
  Future<Either<Failure, String>> submitApplication({
    required ProductType productType,
    required Map<String, dynamic> applicationData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return left(const AuthFailure('User not authenticated.'));
      }

      // BACKEND ENFORCEMENT: Validate KYC status in Firestore
      final profileDoc = await _firestore.collection('profiles').doc(user.uid).get();
      final kycRaw = profileDoc.data()?['kycStatus'] as String? ?? '';
      final isApproved = kycRaw.toLowerCase().contains('approve');

      if (!isApproved) {
        return left(const AuthFailure(
          'Identity Verification (KYC) Required: Your KYC status must be approved by an administrator before applying for banking products.',
        ));
      }
      // BACKEND ENFORCEMENT: Prevent duplicate active applications for the same product
      final existingApps = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: user.uid)
          .where('productType', isEqualTo: productType.value)
          .get();

      final hasActiveApp = existingApps.docs.any((doc) {
        final status = doc.data()['status'] as String? ?? '';
        return status == ApplicationStatus.pending.value ||
            status == ApplicationStatus.underReview.value ||
            status == ApplicationStatus.moreInfoRequired.value;
      });

      if (hasActiveApp) {
        return left(AuthFailure(
          'Application Already In Progress: You already have an active application for ${productType.displayName}. Please track its status under My Applications.',
        ));
      }

      final docRef = _firestore.collection(_collection).doc();
      final app = ProductApplication(
        id: docRef.id,
        userId: user.uid,
        userFullName: user.displayName ?? applicationData['fullName'] as String? ?? 'Applicant',
        userEmail: user.email ?? '',
        productType: productType,
        status: ApplicationStatus.pending,
        submittedAt: DateTime.now(),
        applicationData: applicationData,
      );

      await docRef.set(app.toFirestore());
      return right(docRef.id);
    } catch (e) {
      return left(ServerFailure('Failed to submit application: $e'));
    }
  }

  /// Watch current user's submitted product applications.
  Stream<List<ProductApplication>> watchMyApplications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(ProductApplication.fromFirestore).toList();
      list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      _selfHealApprovedApplications(user.uid, list);
      return list;
    });
  }

  void _selfHealApprovedApplications(String userId, List<ProductApplication> apps) async {
    for (final app in apps) {
      if (app.status == ApplicationStatus.approved) {
        // Idempotency check 1: Has an account with this applicationId already been created?
        final existingByAppId = await _firestore
            .collection('accounts')
            .where('applicationId', isEqualTo: app.id)
            .limit(1)
            .get();

        if (existingByAppId.docs.isNotEmpty) continue;

        final isSavings = app.productType == ProductType.savings;
        final typeName = isSavings ? 'Savings' : 'Current';
        final label = 'SmartBank $typeName Account';

        // Idempotency check 2: Has an account with this label already been created for this user?
        final existingByLabel = await _firestore
            .collection('accounts')
            .where('userId', isEqualTo: userId)
            .where('label', isEqualTo: label)
            .limit(1)
            .get();

        if (existingByLabel.docs.isEmpty) {
          final rawData = app.applicationData;
          final initialDeposit = (rawData != null && rawData['initialDeposit'] is num)
              ? (rawData['initialDeposit'] as num).toDouble()
              : 0.0;
          final typeEnum = isSavings ? 'savings' : 'checking';

          final random = math.Random();
          final accNo = '1009 ${(random.nextInt(8999) + 1000)} ${(random.nextInt(8999) + 1000)}';
          final cardNo = '4532 ${(random.nextInt(8999) + 1000)} ${(random.nextInt(8999) + 1000)} ${(random.nextInt(8999) + 1000)}';

          final accountData = {
            'userId': userId,
            'applicationId': app.id,
            'accountNumber': accNo,
            'cardNumber': cardNo,
            'holderName': app.userFullName,
            'type': typeEnum,
            'label': label,
            'bankName': 'SmartBank',
            'balance': initialDeposit,
            'availableBalance': initialDeposit,
            'currency': 'PHP',
            'cardNetwork': 'visa',
            'cardGradientColors': isSavings
                ? ['#0A84FF', '#5E5CE6']
                : ['#30D158', '#0A84FF'],
            'isDefault': false,
            'linkedAt': DateTime.now().toIso8601String(),
          };

          final accDoc = await _firestore.collection('accounts').add(accountData);

          if (initialDeposit > 0) {
            await _firestore.collection('transactions').add({
              'userId': userId,
              'accountId': accDoc.id,
              'title': 'Approved Account Opening',
              'description': 'Initial deposit for approved $label',
              'amount': initialDeposit,
              'date': FieldValue.serverTimestamp(),
              'category': 'Deposit',
              'status': 'completed',
              'type': 'credit',
            });
          }
        }
      }
    }
  }
}

@riverpod
UserProductApplicationService userProductApplicationService(
    UserProductApplicationServiceRef ref) {
  return UserProductApplicationService();
}

@riverpod
Stream<List<ProductApplication>> myProductApplications(
    MyProductApplicationsRef ref) {
  return ref.watch(userProductApplicationServiceProvider).watchMyApplications();
}
