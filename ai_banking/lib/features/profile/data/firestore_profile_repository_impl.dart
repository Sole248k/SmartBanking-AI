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
        return left(const ServerFailure('Profile not found. Please try logging out and back in to sync your data.'));
      }
      
      return right(UserProfile.fromJson({...doc.data()!, 'id': doc.id}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile) async {
    try {
      await _firestore.collection('profiles').doc(profile.id).set(profile.toJson());
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
        await _firestore.collection('profiles').doc(user.uid).update({'isBiometricEnabled': enabled});
      }
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
