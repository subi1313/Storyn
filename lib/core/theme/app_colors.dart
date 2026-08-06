import 'package:flutter/material.dart';

class AppColors {
  // Common colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFFF3F8F9);

  // Onboarding
  static const Color onboardingButton = Color(0xFF4D8691);
  static const Color dotInactive = Color(0xFFC3DDE0);
  static const Color dotActive = Color(0xFF215D62);

  // Shared gradient for Welcome / Login / Register
  static const LinearGradient authGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    stops: [0.0, 0.41, 1.0],
    colors: [
      Color(0xFF9BCED2),
      Color(0xFFDEE0C0),
      Color(0xFF82C2C7),
    ],
  );
}