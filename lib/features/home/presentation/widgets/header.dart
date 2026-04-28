import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../search/presentation/pages/search_screen.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
      padding: const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 20),
      child: _buildSearchField(context),
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

  //Widget _messenger() {}
}
