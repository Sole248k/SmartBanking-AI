import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/bank_utils.dart';

class UserProvisioningService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Provisions all initial Firestore documents for a new user.
  /// Safe to call multiple times (idempotent).
  Future<void> provisionNewUser({
    required String uid,
    required String email,
    required String fullName,
    String? forcedAccountNumber,
  }) async {
    final profileRef = _firestore.collection('profiles').doc(uid);
    final profileSnapshot = await profileRef.get();

    // 1. Create or update Profile document
    if (!profileSnapshot.exists) {
      await profileRef.set({
        'fullName': fullName,
        'email': email,
        'kycStatus': 'Not Started',
        'isBiometricEnabled': false,
        'pushNotificationsEnabled': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      final data = profileSnapshot.data()!;
      final updates = <String, dynamic>{};
      // Self-heal: update generic name
      if ((data['fullName'] == 'SmartBank User' || data['fullName'] == null) &&
          fullName != 'SmartBank User') {
        updates['fullName'] = fullName;
      }
      // Self-heal: ensure email is always present
      if (data['email'] == null || (data['email'] as String).isEmpty) {
        updates['email'] = email;
      }
      if (updates.isNotEmpty) {
        await profileRef.update(updates);
      }
    }

    // 2. Create Initial Savings Account if none exist
    final accounts = await _firestore
        .collection('accounts')
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    String? accountId;
    if (accounts.docs.isEmpty) {
      final newAccountRef = await _firestore.collection('accounts').add({
        'userId': uid,
        'accountNumber': forcedAccountNumber ?? BankUtils.generateAccountNumber(),
        'cardNumber': BankUtils.generateCardNumber(),
        'cvv': BankUtils.generateCVV(),
        'expiryDate': BankUtils.generateExpiryDate(),
        'holderName': fullName.toUpperCase(),
        'balance': 0.0,
        'availableBalance': 0.0,
        'currency': 'PHP',
        'type': 'savings',
        'label': 'Initial Savings',
        'status': 'active',
        'cardNetwork': 'visa',
        'cardGradientColors': ['#0A84FF', '#5E5CE6'],
      });
      accountId = newAccountRef.id;
    } else {
      accountId = accounts.docs.first.id;
    }

    // 3. Create Wallet if none exists
    final wallets = await _firestore
        .collection('wallets')
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    if (wallets.docs.isEmpty) {
      await _firestore.collection('wallets').add({
        'userId': uid,
        'balance': 0.0,
        'currency': 'PHP',
        'linkedAccountIds': [accountId],
      });
    }
  }
}
