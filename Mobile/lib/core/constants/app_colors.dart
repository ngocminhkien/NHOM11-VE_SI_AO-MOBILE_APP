import 'package:flutter/material.dart';

class AppColors {
  // Gradients cho các thẻ quan trọng
  static const LinearGradient alertGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF448AFF), Color(0xFF2979FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Màu nền soft
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color cardShadow = Color(0x1A000000);
  
  // Màu định danh cho các thẻ Stat
  static const Color accentBlue = Color(0xFF00B0FF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentOrange = Color(0xFFFFAB40);
  static const Color accentRed = Color(0xFFFF5252);
}