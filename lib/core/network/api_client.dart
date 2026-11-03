import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

/// Centralized HTTP client wrapper providing resilient network communication with Spring Boot.
class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient({
    Dio? dio,
    TokenStorage? tokenStorage,
    void Function()? onUnauthorized,
  })  : _tokenStorage = tokenStorage ?? TokenStorage(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
                sendTimeout: ApiConfig.sendTimeout,
                headers: const <String, String>{
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: _tokenStorage,
        onUnauthorized: onUnauthorized,
      ),
    );
  }

  Dio get dio => _dio;
  TokenStorage get tokenStorage => _tokenStorage;

  /// Executes an HTTP GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Executes an HTTP POST request.
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Executes an HTTP PUT request.
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Executes an HTTP DELETE request.
  Future<Response<T>> delete<T>(
    String path,
  ) async {
    try {
      return await _dio.delete<T>(
        path,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

/// Global provider for the shared ApiClient instance.
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: tokenStorage);
});
