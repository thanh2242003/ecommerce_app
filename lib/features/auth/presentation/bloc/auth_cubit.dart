// lib/features/auth/presentation/bloc/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final LogoutUseCase logoutUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;

  AuthCubit({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.logoutUseCase,
    required this.refreshTokenUseCase,
  }) : super(AuthInitial());

  Future<void> signUp(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await signUpUseCase(name, email, password);
      await _saveTokens(response.accessToken, response.refreshToken);
      emit(AuthAuthenticated(response.user, response.accessToken, response.refreshToken));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await signInUseCase(email, password);
      await _saveTokens(response.accessToken, response.refreshToken);
      emit(AuthAuthenticated(response.user, response.accessToken, response.refreshToken));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    if (accessToken.isNotEmpty) {
      try {
        await logoutUseCase(accessToken);
      } catch (e) {
        // Ignore logout errors
      }
    }
    await _clearTokens();
    emit(AuthInitial());
  }

  Future<void> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken') ?? '';
    if (refreshToken.isNotEmpty) {
      emit(AuthLoading());
      try {
        final response = await refreshTokenUseCase(refreshToken);
        await _saveTokens(response.accessToken, response.refreshToken);
        emit(AuthAuthenticated(response.user, response.accessToken, response.refreshToken));
      } catch (e) {
        await _clearTokens();
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }
}