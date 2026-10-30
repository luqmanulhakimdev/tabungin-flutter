import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Flag synced with active theme for instant reactive color adaptation
  static bool isDarkMode = false;

  // Primary Palette (Emerald & Mint)
  static const Color primary = Color(0xFF059669); // Emerald 600
  static const Color primaryLight = Color(0xFF10B981); // Emerald 500
  static const Color primaryDark = Color(0xFF047857); // Emerald 700
  static Color get primarySubtle =>
      isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);
  static const Color mintAccent = Color(0xFFA7F3D0); // Mint 200

  // Secondary & Accent
  static const Color accent = Color(0xFF0284C7); // Sky 600

  // Financial Semantics
  static const Color income = Color(0xFF059669);
  static Color get incomeSubtle =>
      isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
  static const Color expense = Color(0xFFDC2626); // Red 600
  static Color get expenseSubtle =>
      isDarkMode ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);

  // Light Theme Static Tokens
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightDivider = Color(0xFFF1F5F9); // Slate 100
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightTextMuted = Color(0xFF94A3B8); // Slate 400

  // Dark Theme Static Tokens
  static const Color darkBackground = Color(0xFF0B1120); // Deep Slate 950
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF1E293B); // Slate 800
  static const Color darkBorder = Color(0xFF334155); // Slate 700
  static const Color darkDivider = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextMuted = Color(0xFF64748B); // Slate 500

  // Dynamic Neutral Colors
  static Color get background => isDarkMode ? darkBackground : lightBackground;
  static Color get surface => isDarkMode ? darkSurface : lightSurface;
  static Color get card => isDarkMode ? darkCard : lightCard;
  static Color get border => isDarkMode ? darkBorder : lightBorder;
  static Color get divider => isDarkMode ? darkDivider : lightDivider;

  // Dynamic Text Colors
  static Color get textPrimary =>
      isDarkMode ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary =>
      isDarkMode ? darkTextSecondary : lightTextSecondary;
  static Color get textMuted => isDarkMode ? darkTextMuted : lightTextMuted;
  static const Color textOnPrimary = Colors.white;

  // Dynamic Shadow
  static Color get shadow => isDarkMode
      ? Colors.black.withValues(alpha: 0.35)
      : const Color(0xFF0F172A).withValues(alpha: 0.05);
}
