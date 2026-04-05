import '../entities/user.dart';

abstract class UserRepository {
  Future<UserEntity> getUser({
    required String userId,
    required String token,
  });
}
