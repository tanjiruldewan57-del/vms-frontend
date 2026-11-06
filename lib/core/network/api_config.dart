import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Configuration settings for the Stark Group VMS Spring Boot REST API.
class ApiConfig {
  const ApiConfig._();

  /// Configurable base URL for development and production environments.
  /// Defaults to live deployed Render backend in release/production mode,
  /// and falls back to local Spring Boot (http://127.0.0.1:8080/api/v1) in debug mode.
  /// Override at build/runtime via:
  /// `--dart-define=API_BASE_URL=https://vms-backend-7inh.onrender.com/api/v1`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kDebugMode
        ? AppConstants.devApiBaseUrl
        : AppConstants.prodApiBaseUrl,
  );

  // Network Timeouts (Extended slightly to accommodate Render cold start spin-ups)
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Endpoints (Matching Spring Boot @RequestMapping exact paths)
  static const String authLoginEndpoint = '/auth/login';
  static const String vehiclesEndpoint = '/vehicles';
  static String vehicleByIdEndpoint(int id) => '/vehicles/$id';
  static String vehicleByNumberEndpoint(String number) => '/vehicles/number/$number';
}
