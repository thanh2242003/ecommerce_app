import '../repositories/auth_repository.dart';
import '../../data/models/auth_response_model.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<AuthResponseModel> call(String email, String password) {
    return repository.signIn(email, password);
  }
}