import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../models/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);
  Future<Either<Failure, void>> toggleBiometrics(bool enabled);
}
