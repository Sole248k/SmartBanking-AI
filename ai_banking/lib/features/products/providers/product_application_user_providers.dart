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
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ProductApplication.fromFirestore).toList());
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
