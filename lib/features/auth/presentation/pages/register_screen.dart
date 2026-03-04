import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    Text(
                      'Đăng ký',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h1,
                        Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    //TextField Email
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Nhập email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                    ),
                    const SizedBox(height: 20),
                    //TextField Mật khẩu
                    AppTextField(
                      label: 'Mật khẩu',
                      hint: 'Nhập mật khẩu',
                      controller: _passwordController,
                      isPassword: true,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Mật khẩu',
                      hint: 'Nhập lại mật khẩu',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        data: 'ĐĂNG KÝ',
                        borderColor: Colors.blue,
                        textStyle: AppTextStyle.withColor(AppTextStyle.buttonMedium, Colors.black),
                        onTap: () {},
                      ),
                    ),
                    // Hiển thị vòng xoay loading
                    if (state is AuthLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: CircularProgressIndicator(),
                      ),

                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        text: 'Bạn đã có tài khoản? ',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyMedium,
                          Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Đăng nhập ngay',
                            style: AppTextStyle.withColor(AppTextStyle.buttonMedium, Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Chặn điều hướng nếu đang loading
                                if (state is AuthLoading) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const LoginScreen();
                                    },
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
