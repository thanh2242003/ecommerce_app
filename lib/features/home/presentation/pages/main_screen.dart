import 'package:flutter/material.dart';

import '../widgets/header.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Header(),
            //Categories(),
            //NewIn(),
            //TopSelling(),
          ],
        ),
      ),
    );
  }
}
