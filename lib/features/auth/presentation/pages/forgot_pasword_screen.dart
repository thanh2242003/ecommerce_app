import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

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
                    //const SizedBox(height: 65),
                    Text(
                      'Quên mật khẩu',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h1,
                        Colors.black,
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      'Nhập email của bạn để chúng tôi gửi lại mật khẩu',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Nhập email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                    ),
                    const SizedBox(height: 20),
                    if (state is AuthLoading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          data: 'Gửi email',
                          borderColor: Colors.blue,
                          textStyle: AppTextStyle.withColor(
                            AppTextStyle.buttonMedium,
                            Colors.black,
                          ),
                          onTap: () {},
                        ),
                      ),
                    const SizedBox(height: 65),
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
