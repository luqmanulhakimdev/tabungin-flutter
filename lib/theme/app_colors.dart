import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette (Emerald & Mint)
  static const Color primary = Color(0xFF059669); // Emerald 600
  static const Color primaryLight = Color(0xFF10B981); // Emerald 500
  static const Color primaryDark = Color(0xFF047857); // Emerald 700
  static const Color primarySubtle = Color(0xFFECFDF5); // Emerald 50
  static const Color mintAccent = Color(0xFFA7F3D0); // Mint 200

  // Secondary & Accent
  static const Color accent = Color(0xFF0284C7); // Sky 600

  // Financial Semantics
  static const Color income = Color(0xFF059669);
  static const Color incomeSubtle = Color(0xFFD1FAE5);
  static const Color expense = Color(0xFFDC2626); // Red 600
  static const Color expenseSubtle = Color(0xFFFEE2E2);

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFF1F5F9); // Slate 100

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary = Colors.white;

  // Shadow
  static Color shadow = const Color(0xFF0F172A).withValues(alpha: 0.05);
}
