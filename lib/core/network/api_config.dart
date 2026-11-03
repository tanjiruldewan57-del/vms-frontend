/// Configuration settings for the Stark Group VMS Spring Boot REST API.
class ApiConfig {
  const ApiConfig._();

  /// Configurable base URL for development and production environments.
  /// Override at build/runtime via:
  /// `--dart-define=API_BASE_URL=https://api.vms.starkgroup.com/api/v1`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080/api/v1',
  );

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Endpoints (Matching Spring Boot @RequestMapping exact paths)
  static const String vehiclesEndpoint = '/vehicles';
  static String vehicleByIdEndpoint(int id) => '/vehicles/$id';
  static String vehicleByNumberEndpoint(String number) => '/vehicles/number/$number';
}

