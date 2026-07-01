// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // ============ PRIMARY COLORS (Dynamic Theme) ============
  static Color primaryBlue = const Color(0xFF1A73E8);
  static Color primaryBlueDark = const Color(0xFF1557B0);
  static Color primaryBlueLight = const Color(0xFFE8F0FE);
  static Color primaryBlueAccent = const Color(0xFF4285F4);

  // ============ SECONDARY COLORS (Red Accent) ============
  static const Color accentRed = Color(0xFFEA4335);
  static const Color accentRedDark = Color(0xFFC5221F);
  static const Color accentRedLight = Color(0xFFFCE8E6);

  // ============ NEUTRAL COLORS ============
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color lightGray = Color(0xFFF1F3F4);
  static const Color mediumGray = Color(0xFF9AA0A6);
  static const Color darkGray = Color(0xFF5F6368);
  static const Color nearBlack = Color(0xFF202124);

  // ============ STATUS COLORS ============
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color error = Color(0xFFEA4335);
  static const Color info = Color(0xFF1A73E8);

  // ============ CODE BLOCK COLORS ============
  static const Color codeBackground = Color(0xFF1E1E1E);
  static const Color codeText = Color(0xFFD4D4D4);
  static const Color codeNumber = Color(0xFFB5CEA8);
  static const Color codeString = Color(0xFFCE9178);
  static const Color codeKeyword = Color(0xFFC586C0);
  static const Color codeComment = Color(0xFF6A9955);

  // ============ GRADIENTS ============
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF1557B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFEA4335), Color(0xFFC5221F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF34A853), Color(0xFF1E8E3E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
