import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _comfirmPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isLoading = false;

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
                  'Đăng ký',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 33,
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
                  controller: _comfirmPasswordController,
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
                    onTap: () {},
                  ),
                ),
                // Hiển thị vòng xoay loading
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: CircularProgressIndicator(),
                  ),

                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: 'Bạn đã có tài khoản? ',
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                    children: [
                      TextSpan(
                        text: 'Đăng nhập ngay',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Chặn điều hướng nếu đang loading
                            if (_isLoading) return;
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
}
