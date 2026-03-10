import 'package:flutter/material.dart';

import '../widgets/categories.dart';
import '../widgets/header.dart';
import '../widgets/new_product.dart';
import '../widgets/top_selling.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Header(),
            Categories(),
            TopSelling(),
            NewProduct(),
          ],
        ),
      ),
    );
  }
}
