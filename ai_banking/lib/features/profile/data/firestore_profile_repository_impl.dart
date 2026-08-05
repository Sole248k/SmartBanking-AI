import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';

class FirestoreProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return left(const AuthFailure('User not logged in'));

      final doc = await _firestore.collection('profiles').doc(user.uid).get();

      if (!doc.exists) {
        // Self-heal: create the profile document from Firebase Auth data
        // so the user always sees their data even if provisioning was slow.
        final profileData = {
          'fullName': user.displayName ?? 'SmartBank User',
          'email': user.email ?? '',
          'kycStatus': 'Not Started',
          'isBiometricEnabled': false,
          'pushNotificationsEnabled': true,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('profiles').doc(user.uid).set(profileData);
        return right(UserProfile(
          id: user.uid,
          fullName: user.displayName ?? 'SmartBank User',
          email: user.email ?? '',
        ));
      }

      final data = doc.data()!;
      // Ensure email is always populated (self-heal for older records)
      if (data['email'] == null || (data['email'] as String).isEmpty) {
        await _firestore
            .collection('profiles')
            .doc(user.uid)
            .update({'email': user.email ?? ''});
        data['email'] = user.email ?? '';
      }

      return right(UserProfile.fromJson({...data, 'id': doc.id}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('profiles')
          .doc(profile.id)
          .set(profile.toJson(), SetOptions(merge: true));
      return right(profile);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleBiometrics(bool enabled) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('profiles')
            .doc(user.uid)
            .update({'isBiometricEnabled': enabled});
      }
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
