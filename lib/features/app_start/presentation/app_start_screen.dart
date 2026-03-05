import 'package:ecommerce_app/features/app_start/presentation/bloc/app_start_state.dart';
import 'package:ecommerce_app/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/presentation/pages/login_screen.dart';
import '../../home/presentation/pages/main_screen.dart';
import '../../onboarding/presentation/pages/onboarding_screen.dart';
import 'bloc/app_start_cubit.dart';

class AppStartScreen extends StatelessWidget {
  const AppStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStartCubit, AppStartState>(
        builder: (context, state) {
          if (state is AppStartLoading) {
            return SplashScreen();
          }
          else if (state is AppStartOnboarding) {
            return OnboardingScreen();
          }
          else if (state is AppStartUnauthenticated) {
            return LoginScreen();
          }
          else if (state is AppStartAuthenticated) {
            return MainScreen();
          }
          else {
            return SizedBox();
          }
        },
    );
  }
}