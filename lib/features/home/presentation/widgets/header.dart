import 'package:ecommerce_app/features/cart/presentation/pages/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../search/presentation/pages/search_screen.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
      padding: const EdgeInsets.all(20),
      //se thay bang state, cubit cua cart
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Row(
            children: [
              Expanded(child: _buildSearchField(context)),
              const SizedBox(width: 10),
              _card(context),
              //const SizedBox(width: 10),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.search),
        hintText: 'search',
        hintStyle: TextStyle(color: AppColors.primaryColor),
      ),
    );
  }

  Widget _card(BuildContext context) {
    return IconButton(
      iconSize: 32,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartScreen()),
        );
      },
      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
    );
  }

  //Widget _messenger() {}
}
