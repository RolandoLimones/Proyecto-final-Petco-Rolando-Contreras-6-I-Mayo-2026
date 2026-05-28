import 'package:flutter/material.dart';

class AppColors {
  // Color Palette
  static const Color primaryBlue = Color(0xFFA3C6F2);
  static const Color darkBlue = Color(0xFF6EA8FE);
  static const Color primaryRed = Color(0xFFF9B5AC);
  static const Color darkRed = Color(0xFFF48B7A);
  static const Color background = Color(0xFFF4F7FC);
  static const Color textPrimary = Color(0xFF1E2A3A);
  static const Color textSecondary = Color(0xFF5A6E7F);
  static const Color border = Color(0xFFD0DFF0);
  
  // Shadows
  static const Color shadow = Color(0x33A3C6F2); // #A3C6F2 with 0.2 opacity (0x33)

  // Glassmorphic backgrounds (white with opacity)
  static Color glassBackground = Colors.white.withOpacity(0.65);
  static Color glassBorder = Colors.white.withOpacity(0.4);

  // Predefined Glassmorphism decorations
  static BoxDecoration glassDecoration({
    double borderRadius = 16.0,
    Color? customColor,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: customColor ?? glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: glassBorder,
        width: 1.0,
      ),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: shadow,
                offset: const Offset(0, 4),
                blurRadius: 20.0,
                spreadRadius: 0.0,
              )
            ]
          : [],
    );
  }
}
