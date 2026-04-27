import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class OrderReviewScreen extends StatelessWidget {
  const OrderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.lightBackground,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Đánh giá',
          style: AppTextStyle.withColor(AppTextStyle.h3, Colors.black87),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Danh sách sản phẩm chờ đánh giá sẽ hiển thị tại đây.',
            textAlign: TextAlign.center,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
