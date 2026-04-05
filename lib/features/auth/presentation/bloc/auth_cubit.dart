// lib/features/auth/presentation/bloc/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
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
      emit(
        AuthAuthenticated(
          response.user,
          response.accessToken,
          response.refreshToken,
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await signInUseCase(email, password);
      emit(
        AuthAuthenticated(
          response.user,
          response.accessToken,
          response.refreshToken,
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase();
    } catch (e) {
      // Ignore logout errors
    }
    emit(AuthInitial());
  }

  Future<void> refreshToken() async {
    emit(AuthLoading());
    try {
      final response = await refreshTokenUseCase();
      emit(
        AuthAuthenticated(
          response.user,
          response.accessToken,
          response.refreshToken,
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
