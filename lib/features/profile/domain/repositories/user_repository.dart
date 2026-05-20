import '../entities/user.dart';

abstract class UserRepository {
  Future<UserEntity> getUser({required String userId, required String token});

  Future<UserEntity> updateUser({
    required String userId,
    required String token,
    required String name,
    required String phone,
    required String address,
    String? avatar,
    String? avatarFilePath,
  });
}
