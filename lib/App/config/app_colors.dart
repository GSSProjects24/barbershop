import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGold = Color(0xFFD4AF37); // Rich gold
  static const Color lightGold = Color(0xFFF7E7CE); // Light gold
  static const Color accentAmber = Color(0xFFFFC107); // Amber yellow
  static const Color darkGold = Color(0xFFB8860B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color crimson = Color(0xFF8B0000);
  static const Color success = Color(0xFF10B981);
// At the top of your file, add these color constants for consistency

  // Gradient for premium feel
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF2D2D2D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
