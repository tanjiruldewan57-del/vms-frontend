/// Application-wide constants for the Stark Group Vehicle Management System (VMS).
class AppConstants {
  const AppConstants._();

  // Branding (Stark Group Corporate & Fleet Identity)
  static const String appName = 'Stark Group Fleet Portal';
  static const String appShortName = 'STARK VMS';
  static const String appTagline = 'Vehicle & Heavy Distribution Logistics';
  static const String appVersion = 'v1.0.0-web';

  // Responsive Layout Breakpoints (pixels)
  static const double desktopBreakpoint = 1024.0;
  static const double tabletBreakpoint = 640.0;
  static const double maxContentWidth = 1440.0;

  // Navigation Dimensions
  static const double sidebarExpandedWidth = 260.0;
  static const double topNavBarHeight = 64.0;

  // Route Paths
  static const String routeLogin = '/login';
  static const String routeVehicles = '/vehicles';
  static const String routeVehicleCreate = '/vehicles/new';
  static const String routeVehicleEdit = '/vehicles/:id/edit';

  // Demo Credentials for Evaluators & Administrators
  static const String demoEmail = 'fleet.admin@starkgroup.com';
  static const String demoPassword = 'StarkFleet2024!';
}
