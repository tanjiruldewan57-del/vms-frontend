import 'package:flutter/material.dart';

/// Semantic and brand color definitions for the VMS Admin portal.
class AppColors {
  const AppColors._();

  // Brand Primaries
  static const Color primary = Color(0xFF0284C7); // Sky 600
  static const Color primaryHover = Color(0xFF0369A1); // Sky 700
  static const Color primaryLight = Color(0xFF38BDF8); // Sky 400

  // Dark Palette (Default desktop theme)
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Status Indicator Colors
  static const Color statusActive = Color(0xFF10B981); // Emerald 500
  static const Color statusActiveBg = Color(0x1A10B981);
  static const Color statusMaintenance = Color(0xFFF59E0B); // Amber 500
  static const Color statusMaintenanceBg = Color(0x1AF59E0B);
  static const Color statusOutOfService = Color(0xFFEF4444); // Red 500
  static const Color statusOutOfServiceBg = Color(0x1AEF4444);

  // Neutral Accents
  static const Color dividerDark = Color(0xFF1E293B);
  static const Color dividerLight = Color(0xFFE2E8F0);
}

