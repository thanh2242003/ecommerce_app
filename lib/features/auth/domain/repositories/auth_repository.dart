import '../../data/models/auth_response_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> signUp(String name, String email, String password);
  Future<AuthResponseModel> signIn(String email, String password);
  Future<void> logout(String accessToken);
  Future<AuthResponseModel> refreshToken(String refreshToken);
}