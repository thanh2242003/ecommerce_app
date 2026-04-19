import 'package:flutter/material.dart';

import '../widgets/categories.dart';
import '../widgets/header.dart';
import '../widgets/new_product.dart';
import '../widgets/recommendations.dart';
import '../widgets/top_selling.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Recommendations.provider(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: const [
              Header(),
              Categories(),
              TopSelling(),
              NewProduct(),
              Recommendations(),
            ],
          ),
        ),
      ),
    );
  }
}
