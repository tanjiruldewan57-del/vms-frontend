import 'package:dio/dio.dart';

/// Structured application exception representing Spring Boot REST API failures.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? error;
  final String? path;
  final Map<String, String>? fieldErrors;

  const ApiException({
    this.statusCode,
    required this.message,
    this.error,
    this.path,
    this.fieldErrors,
  });

  /// Factory constructor to parse and normalize DioException instances.
  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionError:
        return const ApiException(
          statusCode: null,
          message: 'Unable to connect to the Spring Boot backend service at 127.0.0.1:8080. '
              'Please ensure the backend application is running.',
          error: 'Connection Refused',
        );

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          statusCode: 408,
          message: 'Network request timed out while communicating with the server.',
          error: 'Timeout',
        );

      case DioExceptionType.badResponse:
        final response = dioException.response;
        if (response != null && response.data != null) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            final statusCode = data['status'] as int? ?? response.statusCode;
            String message = data['message'] as String? ?? '';
            final error = data['error'] as String?;
            final path = data['path'] as String?;

            if (statusCode == 409 ||
                message.toLowerCase().contains('already exists') ||
                message.toLowerCase().contains('duplicate')) {
              message = 'Vehicle number already exists in the fleet';
            } else if (message.isEmpty || message == 'Unauthorized') {
              if (statusCode == 401) {
                message = 'Invalid email or password. Please verify your credentials.';
              } else {
                message = 'An unexpected server error occurred.';
              }
            }

            Map<String, String>? fieldErrors;
            if (data['fieldErrors'] is List) {
              final list = data['fieldErrors'] as List<dynamic>;
              fieldErrors = <String, String>{};
              for (final item in list) {
                if (item is Map<String, dynamic>) {
                  final field = item['field'] as String?;
                  final msg = item['message'] as String?;
                  if (field != null && msg != null) {
                    fieldErrors[field] = msg;
                  }
                }
              }
            }

            return ApiException(
              statusCode: statusCode,
              message: message,
              error: error,
              path: path,
              fieldErrors: fieldErrors,
            );
          }
        }
        final statusCode = response?.statusCode;
        final String message;
        if (statusCode == 409) {
          message = 'Vehicle number already exists in the fleet';
        } else if (statusCode == 401) {
          message = 'Invalid email or password. Please verify your credentials.';
        } else {
          message = 'Server returned HTTP $statusCode error.';
        }
        return ApiException(
          statusCode: statusCode,
          message: message,
          error: response?.statusMessage,
        );

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
          error: 'Cancelled',
        );

      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'SSL certificate verification failed.',
          error: 'Bad Certificate',
        );

      case DioExceptionType.unknown:
        return ApiException(
          message: dioException.message ?? 'An unknown network error occurred.',
          error: 'Unknown',
        );

      default:
        return ApiException(
          message: dioException.message ?? 'An unexpected network error occurred.',
          error: 'Network Error',
        );
    }
  }

  @override
  String toString() => message;
}

