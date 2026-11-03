import 'package:dio/dio.dart';
import 'api_config.dart';
import 'token_storage.dart';

/// Dio interceptor providing automatic JWT Bearer token attachment
/// and global handling of 401 Unauthorized responses from protected endpoints.
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final void Function()? _onUnauthorized;

  AuthInterceptor({
    required TokenStorage tokenStorage,
    void Function()? onUnauthorized,
  })  : _tokenStorage = tokenStorage,
        _onUnauthorized = onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Attach JWT Bearer token to all outbound requests if session is active
    final token = _tokenStorage.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If a 401 Unauthorized is received from any protected API,
    // clear the session and notify redirect handlers to return to login.
    if (err.response?.statusCode == 401) {
      final isLoginPath = err.requestOptions.path.contains(ApiConfig.authLoginEndpoint);
      if (!isLoginPath) {
        _tokenStorage.clearSession();
        _onUnauthorized?.call();
      }
    }
    handler.next(err);
  }
}
