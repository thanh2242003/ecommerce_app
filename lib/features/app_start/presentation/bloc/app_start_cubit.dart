import 'package:ecommerce_app/features/app_start/presentation/bloc/app_start_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStartCubit extends Cubit<AppStartState> {
  AppStartCubit() : super(AppStartLoading()) {
    checkAppStart();
  }

  /// CHECK APP START
  Future<void> checkAppStart() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();

    final bool seenOnboarding =
        prefs.getBool("seen_onboarding") ?? false;

    final bool isLoggedIn =
        prefs.getBool("is_logged_in") ?? false;

    if (!seenOnboarding) {
      emit(AppStartOnboarding());
    } else if (!isLoggedIn) {
      emit(AppStartUnauthenticated());
    } else {
      emit(AppStartAuthenticated());
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

    await prefs.setBool("is_logged_in", true);

    emit(AppStartAuthenticated());
  }

  /// LOGOUT
  Future<void> goToLogin() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("is_logged_in", false);

    emit(AppStartUnauthenticated());
  }
}
