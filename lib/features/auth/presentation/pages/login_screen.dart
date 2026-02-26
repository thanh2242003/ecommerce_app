import 'package:ecommerce_app/core/widgets/app_button.dart';
import 'package:ecommerce_app/features/auth/presentation/pages/register_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 33,
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
                const SizedBox(height: 40),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      data: 'ĐĂNG NHẬP',
                      borderColor: Colors.blue,
                      onTap: () {},
                    ),
                  ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: 'Bạn chưa có tài khoản? ',
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                    children: [
                      TextSpan(
                        text: 'Đăng ký ngay',
                        style: const TextStyle(color: Colors.blue, fontSize: 18),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const RegisterScreen();
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
}
