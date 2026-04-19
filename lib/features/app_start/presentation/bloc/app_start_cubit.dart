import 'package:ecommerce_app/features/app_start/presentation/bloc/app_start_state.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppStartCubit extends Cubit<AppStartState> {
  AppStartCubit({required this.authRepository, required this.tokenStorage})
    : super(AppStartLoading()) {
    checkAppStart();
  }

  final AuthRepository authRepository;
  final TokenStorage tokenStorage;

  /// CHECK APP START
  Future<void> checkAppStart() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();

    final bool seenOnboarding = prefs.getBool("seen_onboarding") ?? false;

    if (!seenOnboarding) {
      emit(AppStartOnboarding());
    } else {
      await _resolveSession();
    }
  }

  Future<void> _resolveSession() async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken != null &&
        accessToken.isNotEmpty &&
        !_isJwtExpired(accessToken)) {
      emit(AppStartAuthenticated());
      return;
    }

    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      emit(AppStartUnauthenticated());
      return;
    }

    try {
      await authRepository.refreshToken();
      emit(AppStartAuthenticated());
    } catch (_) {
      await tokenStorage.clearTokens();
      emit(AppStartUnauthenticated());
    }
  }

  bool _isJwtExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }

      final payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! num) {
        return true;
      }

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true;
    }
  }

  /// COMPLETE ONBOARDING
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("seen_onboarding", true);

    emit(AppStartUnauthenticated());
  }

  /// LOGIN SUCCESS
  Future<void> goToHome() async {
    final prefs = await SharedPreferences.getInstance();

    // Keep this for backward compatibility with existing app flows.
    await prefs.setBool("is_logged_in", true);

    emit(AppStartAuthenticated());
  }

  /// LOGOUT
  Future<void> goToLogin() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("is_logged_in", false);
    await tokenStorage.clearTokens();

    emit(AppStartUnauthenticated());
  }
}
