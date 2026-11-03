import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../domain/auth_models.dart';

/// Direct HTTP service for Spring Boot authentication endpoints.
class AuthApiService {
  final ApiClient _client;

  const AuthApiService(this._client);

  /// Authenticates user credentials via `POST /api/v1/auth/login`.
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConfig.authLoginEndpoint,
      data: request.toJson(),
    );

    final rootData = response.data;
    if (rootData == null || rootData['data'] == null) {
      throw const ApiException(
        message: 'Empty response received from authentication server.',
      );
    }

    final dataJson = rootData['data'] as Map<String, dynamic>;
    return AuthResponse.fromJson(dataJson);
  }
}

/// Global provider for AuthApiService.
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApiService(apiClient);
});

