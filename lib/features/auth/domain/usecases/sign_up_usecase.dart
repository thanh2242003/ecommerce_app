import '../repositories/auth_repository.dart';
import '../../data/models/auth_response_model.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AuthResponseModel> call(String name, String email, String password) {
    return repository.signUp(name, email, password);
  }
}