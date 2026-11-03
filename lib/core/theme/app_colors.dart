import 'package:flutter/material.dart';

/// Semantic, brand, and status color definitions reflecting the Stark Group corporate visual style.
class AppColors {
  const AppColors._();

  // Stark Group Signature Primaries (Industrial Orange & Slate Navy)
  static const Color starkOrange = Color(0xFFEA580C); // Stark Industrial Orange
  static const Color starkOrangeHover = Color(0xFFC2410C); // Deep Burnt Orange
  static const Color starkOrangeLight = Color(0xFFFB923C); // Safety High-Vis Accent
  static const Color starkNavy = Color(0xFF0F172A); // Scandinavian Corporate Navy

  // Neutral Dark Palette (Default Stark Logistics Admin Theme)
  static const Color darkBackground = Color(0xFF0B111E);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Neutral Light Palette (Clean High-Contrast Enterprise Theme)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Operational Fleet Status Indicators
  static const Color statusActive = Color(0xFF10B981); // Emerald Green
  static const Color statusActiveBg = Color(0x1A10B981);
  static const Color statusMaintenance = Color(0xFFF59E0B); // Amber Warning
  static const Color statusMaintenanceBg = Color(0x1AF59E0B);
  static const Color statusOutOfService = Color(0xFFEF4444); // Crimson Out of Service
  static const Color statusOutOfServiceBg = Color(0x1AEF4444);
}
