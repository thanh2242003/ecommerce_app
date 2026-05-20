import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';
import '../sources/user_api_service.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApiService apiService;

  UserRepositoryImpl(this.apiService);

  @override
  Future<UserEntity> getUser({
    required String userId,
    required String token,
  }) async {
    final result = await UserApiService.getUser(userId: userId, token: token);
    return result.toEntity();
  }

  @override
  Future<UserEntity> updateUser({
    required String userId,
    required String token,
    required String name,
    required String phone,
    required String address,
    String? avatar,
    String? avatarFilePath,
  }) async {
    final result = await UserApiService.updateUser(
      userId: userId,
      token: token,
      name: name,
      phone: phone,
      address: address,
      avatar: avatar,
      avatarFilePath: avatarFilePath,
    );
    return result.toEntity();
  }
}
