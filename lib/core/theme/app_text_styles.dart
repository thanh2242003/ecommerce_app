import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  //headings
  static TextStyle h1 = GoogleFonts.nunito(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  static TextStyle h2 = GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  static TextStyle h3 = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  //body text
  static TextStyle bodyLarge = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static TextStyle bodyMedium = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static TextStyle bodySmall = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  //button text
  static TextStyle buttonLarge = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static TextStyle buttonMedium = GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  static TextStyle buttonSmall = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  //label text
  static TextStyle labelMedium = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  //helper functions for color variations
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
