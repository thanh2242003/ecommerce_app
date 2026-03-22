// lib/features/auth/data/repositories/auth_repository_impl.dart
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response_model.dart';
import '../sources/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;

  AuthRepositoryImpl(this.apiService);

  @override
  Future<AuthResponseModel> signUp(String name, String email, String password) {
    return apiService.signUp(name: name, email: email, password: password);
  }

  @override
  Future<AuthResponseModel> signIn(String email, String password) {
    return apiService.signIn(email: email, password: password);
  }

  @override
  Future<void> logout(String accessToken) {
    return apiService.logout(accessToken: accessToken);
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) {
    return apiService.refreshToken(refreshToken: refreshToken);
  }
}