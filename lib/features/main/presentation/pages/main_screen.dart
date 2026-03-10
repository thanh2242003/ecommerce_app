import 'package:flutter/material.dart';

import '../../../home/presentation/pages/home_screen.dart';
import '../../../notifications/presentation/pages/notifications_screen.dart';
import '../../../order/presentation/pages/orders_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../widgets/main_bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final pages = [
    HomeScreen(),
    OrdersScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
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
