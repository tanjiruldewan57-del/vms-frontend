import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/vehicles/presentation/vehicle_form_screen.dart';
import '../../features/vehicles/presentation/vehicle_list_screen.dart';

/// Navigation key for top-level navigator.
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Navigation key for shell route navigator.
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Declarative GoRouter configuration with route guards and shell layout.
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppConstants.routeVehicles,
    refreshListenable: authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authNotifier.isAuthenticated;
      final isLoggingIn = state.matchedLocation == AppConstants.routeLogin;

      // Unauthenticated users are redirected to login
      if (!isAuthenticated) {
        return isLoggingIn ? null : AppConstants.routeLogin;
      }

      // Authenticated users hitting login or root are routed to fleet dashboard
      if (isLoggingIn || state.matchedLocation == '/') {
        return AppConstants.routeVehicles;
      }

      return null;
    },
    routes: <RouteBase>[
      // Login Screen Route (outside the application shell)
      GoRoute(
        path: AppConstants.routeLogin,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),

      // Authenticated Application Shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AppShell(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: AppConstants.routeVehicles,
            name: 'vehicles',
            builder: (BuildContext context, GoRouterState state) {
              return const VehicleListScreen();
            },
          ),
          GoRoute(
            path: AppConstants.routeVehicleCreate,
            name: 'vehicle-create',
            builder: (BuildContext context, GoRouterState state) {
              return const VehicleFormScreen();
            },
          ),
          GoRoute(
            path: AppConstants.routeVehicleEdit,
            name: 'vehicle-edit',
            builder: (BuildContext context, GoRouterState state) {
              final vehicleId = state.pathParameters['id'];
              return VehicleFormScreen(vehicleId: vehicleId);
            },
          ),
        ],
      ),
    ],
  );
});

