import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../main/presentation/pages/main_screen.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController(); // Thêm name controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải ít nhất 6 ký tự')),
      );
      return;
    }

    // Gọi signUp
    context.read<AuthCubit>().signUp(name, email, password);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate đến home screen sau khi đăng ký thành công
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>MainScreen())); // Thay bằng route thực tế
        } else if (state is AuthError) {
          // Hiển thị lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

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
                    // Thêm TextField Tên
                    AppTextField(
                      controller: _nameController,
                      label: 'Tên',
                      hint: 'Nhập tên của bạn',
                      keyboardType: TextInputType.name,
                      prefixIcon: Icons.person,
                    ),
                    const SizedBox(height: 20),
                    // TextField Email
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Nhập email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                    ),
                    const SizedBox(height: 20),
                    // TextField Mật khẩu
                    AppTextField(
                      label: 'Mật khẩu',
                      hint: 'Nhập mật khẩu',
                      controller: _passwordController,
                      isPassword: true,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                    ),
                    const SizedBox(height: 20),
                    // TextField Xác nhận mật khẩu
                    AppTextField(
                      label: 'Xác nhận mật khẩu',
                      hint: 'Nhập lại mật khẩu',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                    ),
                    const SizedBox(height: 40),
                    if (isLoading)
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Đang đăng ký...',
                              style: AppTextStyle.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          data: 'ĐĂNG KÝ',
                          borderColor: Colors.blue,
                          textStyle: AppTextStyle.withColor(
                            AppTextStyle.buttonMedium,
                            Colors.black,
                          ),
                          onTap: _onRegisterPressed, // Gọi hàm validation
                        ),
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
                            style: AppTextStyle.withColor(
                              AppTextStyle.buttonMedium,
                              Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Chặn điều hướng nếu đang loading
                                if (isLoading) return;
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}