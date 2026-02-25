import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage(
      {super.key, required this.title, required this.description, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child:Column(
        children: [
          /// IMAGE
          Expanded(
            flex: 5,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),

          //const SizedBox(height: 20),

          /// TITLE
          Text(
            title,
            style: AppTextStyle.withColor(AppTextStyle.h1, Colors.black),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          /// DESCRIPTION
          Text(
            description,
            style: AppTextStyle.withColor(AppTextStyle.bodyLarge, Colors.black),
            textAlign: TextAlign.center,
          ),

          //const Spacer(flex: 2),
        ],
      ),
    );
  }
}