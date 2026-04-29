import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppThemes {
  //light theme
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightBackground,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.nunito().fontFamily,
    appBarTheme: const AppBarTheme(
      //backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      //iconTheme: IconThemeData(color: Colors.black),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      brightness: Brightness.light,
      //surface: Colors.white,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(),
    primaryTextTheme: GoogleFonts.nunitoTextTheme(),
    //cardColor: Colors.white,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      //backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  //dark theme
  static final dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBackground,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.nunito().fontFamily,
    appBarTheme: const AppBarTheme(
      //backgroundColor: const Color(0xFF121212),
      elevation: 0,
      centerTitle: true,
      //iconTheme: IconThemeData(color: Colors.black),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(),
    primaryTextTheme: GoogleFonts.nunitoTextTheme(),
    //cardColor: const Color(0xFF1E1E1E),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      //backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );
}
