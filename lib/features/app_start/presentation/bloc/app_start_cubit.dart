import 'package:ecommerce_app/features/app_start/presentation/bloc/app_start_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppStartCubit extends Cubit<AppStartState> {
  AppStartCubit() : super(AppStartLoading()) {
    checkAppStart();
  }

  Future<void> checkAppStart() async {
    await Future.delayed(const Duration(seconds: 2));
    //thay bang token
    final bool seenOnboarding = false;
    final bool isLoggedIn = false;

    if (!seenOnboarding) {
      emit(AppStartOnboarding());
    } else if (!isLoggedIn) {
      emit(AppStartUnauthenticated());
    } else {
      emit(AppStartAuthenticated());
    }
  }

  void completeOnboarding() {
    emit(AppStartUnauthenticated());
  }

  void goToHome() {
    emit(AppStartAuthenticated());
  }

  void goToLogin() {
    emit(AppStartUnauthenticated());
  }
}

