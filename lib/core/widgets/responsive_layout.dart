import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Responsive helper and layout builder for desktop-first admin screens.
class ResponsiveLayout extends StatelessWidget {
  final Widget desktop;
  final Widget? tablet;
  final Widget? mobile;

  const ResponsiveLayout({
    super.key,
    required this.desktop,
    this.tablet,
    this.mobile,
  });

  /// Check whether the current screen width is desktop-sized (>= 1024px).
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppConstants.desktopBreakpoint;
  }

  /// Check whether current screen width is tablet-sized (640px - 1023px).
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.tabletBreakpoint &&
        width < AppConstants.desktopBreakpoint;
  }

  /// Check whether current screen width is mobile-sized (< 640px).
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < AppConstants.tabletBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (screenWidth >= AppConstants.desktopBreakpoint) {
      return desktop;
    }

    if (screenWidth >= AppConstants.tabletBreakpoint) {
      return tablet ?? desktop;
    }

    return mobile ?? tablet ?? desktop;
  }
}

