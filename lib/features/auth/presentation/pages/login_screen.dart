import 'package:ecommerce_app/core/widgets/app_button.dart';
import 'package:ecommerce_app/features/auth/presentation/pages/register_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'forgot_pasword_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  children: [
                    const SizedBox(height: 65),
                    Text(
                      'Đăng nhập',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h1,
                        Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Nhập email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _passwordController,
                      isPassword: true,
                      label: 'Mật khẩu',
                      hint: 'Nhập mật khẩu',
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: Text(
                          'Quên mật khẩu?',
                          style: AppTextStyle.withColor(
                            AppTextStyle.buttonMedium,
                            Colors.blue,
                          ),
                        ),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (state is AuthLoading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          data: 'ĐĂNG NHẬP',
                          borderColor: Colors.blue,
                          textStyle: AppTextStyle.withColor(AppTextStyle.buttonMedium, Colors.black),
                          onTap: () {},
                        ),
                      ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        text: 'Bạn chưa có tài khoản? ',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyMedium,
                          Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Đăng ký ngay',
                            style: AppTextStyle.withColor(AppTextStyle.buttonMedium, Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return RegisterScreen();
                                    },
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 65),
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
