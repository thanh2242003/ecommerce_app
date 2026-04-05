import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        // tạm thời không làm gì
      },
      icon: Container(
        height: 40,
        width: 40,
        decoration: const BoxDecoration(
          color: AppColors.secondColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.favorite_outline,
          size: 15,
          color: Colors.black,
        ),
      ),
    );
  }
}
