import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  Future<UserEntity> call({
    required String userId,
    required String token,
  }) {
    return repository.getUser(
      userId: userId,
      token: token,
    );
  }
}