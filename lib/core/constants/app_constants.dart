/// Application-wide constants for the Vehicle Management System (VMS).
class AppConstants {
  const AppConstants._();

  // Branding
  static const String appName = 'Vehicle Management System';
  static const String appShortName = 'VMS Admin';
  static const String appVersion = 'v1.0.0-foundation';

  // Responsive Layout Breakpoints (pixels)
  static const double desktopBreakpoint = 1024.0;
  static const double tabletBreakpoint = 640.0;
  static const double maxContentWidth = 1440.0;

  // Sidebar & Navigation Dimensions
  static const double sidebarExpandedWidth = 260.0;
  static const double sidebarCollapsedWidth = 72.0;
  static const double topNavBarHeight = 64.0;

  // Route Paths
  static const String routeLogin = '/login';
  static const String routeVehicles = '/vehicles';
  static const String routeVehicleCreate = '/vehicles/new';
  static const String routeVehicleEdit = '/vehicles/:id/edit';

  // Demo Credentials for Beginner/Evaluation convenience
  static const String demoEmail = 'admin@vms-fleet.io';
  static const String demoPassword = 'password123';
}
