import 'package:flutter/material.dart';

import '../../../cart/presentation/pages/cart_screen.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../notifications/presentation/pages/notifications_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../widgets/main_bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      const CartScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
