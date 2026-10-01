import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFFF4F2E6);
  static const surface = Color(0xFFFCFAEE);
  static const black = Color(0xFF000000);
  static const textGray = Color(0xFF545454);
  static const veryHigh = Color(0xFFD50000);
  static const high = Color(0xFFE85F13);
  static const moderate = Color(0xFFAB7C1C);
  static const low = Color(0xFF0FBF00);
  static const inactive = Color(0xFFA6A6A6);
  static const border = Color(0xFFB4B4B4);
  // Not in your palette list, eyeballed from the design (+ button)
  static const brandOrange = Color(0xFFE8871A); // logo / + button orange
  static const fabOrange = brandOrange;
  static const chipGray = Color(0xFFD9D9D9); // icon boxes, step circles
  static const fabRing = Color(0xFFE6E3CC);
}

class AppText {
  /// DM Sans: Test History, All recorded readings, badges
  static TextStyle dmSans(double size,
          {FontWeight weight = FontWeight.w400,
          Color color = AppColors.black,
          double? letterSpacing}) =>
      GoogleFonts.dmSans(
          fontSize: size,
          fontWeight: weight,
          color: color,
          letterSpacing: letterSpacing,
          height: 1.0);

  /// Arial: everything else.
  /// Note: Android phones don't ship Arial. For the same look on Android,
  /// swap this to GoogleFonts.arimo(...) (same metrics as Arial).
  static TextStyle arial(double size,
          {FontWeight weight = FontWeight.w400,
          Color color = AppColors.black}) =>
      TextStyle(
          fontFamily: 'Arial',
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: 1.0);

  /// Monospace values on Device Status (font not specified in design; DM Mono is a close match)
  static TextStyle mono(double size, {Color color = AppColors.black}) =>
      GoogleFonts.dmMono(fontSize: size, color: color, height: 1.0);
}
