import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/user_cubit.dart';
import '../bloc/user_state.dart';
import 'package:ecommerce_app/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:ecommerce_app/features/auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    // Fetch profile when authenticated.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<UserCubit>().getUser(
              token: authState.accessToken,
              userId: authState.user.id,
            );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {

            ///  Loading
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            ///  Error
            if (state is UserError) {
              return Center(child: Text(state.message));
            }

            ///  Loaded
            if (state is UserLoaded) {
              final user = state.user;

              return Column(
                children: [
                  const SizedBox(height: 20),

                  /// Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user.avatar != null
                        ? NetworkImage(user.avatar!)
                        : null,
                    child: user.avatar == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),

                  const SizedBox(height: 20),

                  /// User info card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.phone ?? 'Chưa có số điện thoại',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),

                        /// Edit
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Chỉnh sửa',
                            style: TextStyle(color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Menu
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: const [
                        _MenuItem(title: 'Địa chỉ'),
                        _MenuItem(title: 'Yêu thích'),
                        _MenuItem(title: 'Thanh toán'),
                        _MenuItem(title: 'Trợ giúp'),
                        _MenuItem(title: 'Hỗ trợ'),
                      ],
                    ),
                  ),

                  /// Sign out
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        // TODO: logout
                      },
                      child: Text(
                        'Đăng xuất',
                        style: AppTextStyle.buttonLarge.copyWith(color: Colors.red),
                      ),
                    ),
                  )
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

/// Menu item widget
class _MenuItem extends StatelessWidget {
  final String title;

  const _MenuItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
