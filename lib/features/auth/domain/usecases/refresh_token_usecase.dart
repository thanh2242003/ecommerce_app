import '../repositories/auth_repository.dart';
import '../../data/models/auth_response_model.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<AuthResponseModel> call() {
    return repository.refreshToken();
  }
}
