import '../entities/user.dart';
import '../repositories/user_repository.dart';

class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  Future<UserEntity> call({
    required String userId,
    required String token,
    required String name,
    required String phone,
    required String address,
    String? avatar,
    String? avatarFilePath,
  }) {
    return repository.updateUser(
      userId: userId,
      token: token,
      name: name,
      phone: phone,
      address: address,
      avatar: avatar,
      avatarFilePath: avatarFilePath,
    );
  }
}
