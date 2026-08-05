import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import 'auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> login(String email, String password);
  Future<Either<Failure, AuthUser>> signInWithGoogle();
  Future<Either<Failure, AuthUser>> register({
    required String email,
    required String password,
    required String fullName,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthUser>> getCurrentUser();
  Stream<AuthUser?> authStateChanges();
}
