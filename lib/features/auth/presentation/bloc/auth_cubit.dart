import 'package:ecommerce_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login() async {
    emit(AuthLoading());

    await Future.delayed(const Duration(seconds: 2)); // giả lập API

    emit(AuthAuthenticated());
  }

  void logout() {
    emit(AuthUnauthenticated());
  }
}

