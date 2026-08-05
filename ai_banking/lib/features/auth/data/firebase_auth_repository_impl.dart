import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../../../core/services/firebase_service/user_provisioning_service.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserProvisioningService _provisioningService = UserProvisioningService();

  @override
  Future<Either<Failure, AuthUser>> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return left(const AuthFailure('Login failed: User is null'));
      }

      final user = credential.user!;

      // Self-heal: Provision Firestore data if missing on login
      await _provisioningService.provisionNewUser(
        uid: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ?? 'SmartBank User',
      );

      return right(_mapFirebaseUser(user));
    } on firebase.FirebaseAuthException catch (e) {
      return left(AuthFailure(e.message ?? 'Authentication error', code: e.code));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithGoogle() async {
    try {
      // Ensure we always prompt for account selection on web
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return left(const AuthFailure('Google Sign-In canceled'));

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase.AuthCredential credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase.UserCredential userCredential = await _auth.signInWithCredential(credential);
      final firebase.User? user = userCredential.user;

      if (user == null) return left(const AuthFailure('Google Sign-In failed'));

      // Provision Firestore data
      await _provisioningService.provisionNewUser(
        uid: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ?? 'Google User',
      );

      return right(_mapFirebaseUser(user));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return left(const AuthFailure('Registration failed: User is null'));
      }

      final user = credential.user!;
      
      // Update display name in Auth
      await user.updateDisplayName(fullName);
      await user.reload();
      
      // Get the fresh user instance after reload to ensure display name is synced
      final freshUser = _auth.currentUser!;

      // Provision Firestore data
      await _provisioningService.provisionNewUser(
        uid: freshUser.uid,
        email: email,
        fullName: fullName,
      );

      return right(_mapFirebaseUser(freshUser));
    } on firebase.FirebaseAuthException catch (e) {
      return left(AuthFailure(e.message ?? 'Registration error', code: e.code));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _auth.signOut();
      return right(null);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return right(_mapFirebaseUser(user));
    }
    return left(const AuthFailure('No user logged in'));
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapFirebaseUser(user);
    });
  }

  AuthUser _mapFirebaseUser(firebase.User user) {
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      fullName: user.displayName ?? 'SmartBank User',
      phoneNumber: user.phoneNumber,
      avatarUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
    );
  }
}
