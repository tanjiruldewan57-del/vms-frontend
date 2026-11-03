import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/core/network/api_client.dart';
import 'package:vms_frontend/core/network/api_config.dart';
import 'package:vms_frontend/core/network/api_exception.dart';
import 'package:vms_frontend/core/network/auth_interceptor.dart';
import 'package:vms_frontend/core/network/token_storage.dart';
import 'package:vms_frontend/features/auth/data/auth_api_service.dart';
import 'package:vms_frontend/features/auth/data/auth_repository.dart';
import 'package:vms_frontend/features/auth/domain/auth_models.dart';
import 'package:vms_frontend/features/auth/presentation/auth_provider.dart';

class FakeAuthApiService extends AuthApiService {
  FakeAuthApiService() : super(ApiClient());

  bool shouldFail = false;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    if (shouldFail) {
      throw const ApiException(
        statusCode: 401,
        message: 'Invalid email or password. Please verify your credentials.',
      );
    }

    return const AuthResponse(
      token: 'fake-jwt-token-xyz',
      user: AuthUser(
        email: 'fleet.admin@starkgroup.com',
        name: 'Fleet Admin',
        role: 'Fleet Administrator',
      ),
    );
  }
}

void main() {
  group('Auth Domain Models', () {
    test('AuthUser and LoginRequest serialize and deserialize correctly', () {
      final user = AuthUser.fromJson(<String, dynamic>{
        'email': 'admin@starkgroup.com',
        'name': 'Stark Admin',
        'role': 'Fleet Manager',
      });

      expect(user.email, 'admin@starkgroup.com');
      expect(user.name, 'Stark Admin');
      expect(user.role, 'Fleet Manager');

      final json = user.toJson();
      expect(json['email'], 'admin@starkgroup.com');

      const loginReq = LoginRequest(
        email: 'admin@starkgroup.com',
        password: 'password123',
      );
      final reqJson = loginReq.toJson();
      expect(reqJson['email'], 'admin@starkgroup.com');
      expect(reqJson['password'], 'password123');
    });

    test('AuthResponse deserializes valid payload', () {
      final authResponse = AuthResponse.fromJson(<String, dynamic>{
        'token': 'jwt-123456',
        'user': <String, dynamic>{
          'email': 'driver@starkgroup.com',
          'name': 'John Doe',
          'role': 'Driver',
        },
      });

      expect(authResponse.token, 'jwt-123456');
      expect(authResponse.user.email, 'driver@starkgroup.com');
    });
  });

  group('TokenStorage', () {
    test('Stores and clears session correctly with notifications', () {
      final storage = TokenStorage();
      int notifyCount = 0;
      storage.addListener(() => notifyCount++);

      expect(storage.hasToken, false);
      expect(storage.token, null);
      expect(storage.user, null);

      storage.saveSession(
        token: 'token-abc',
        user: const AuthUser(
          email: 'test@starkgroup.com',
          name: 'Tester',
          role: 'Admin',
        ),
      );

      expect(storage.hasToken, true);
      expect(storage.token, 'token-abc');
      expect(storage.user?.email, 'test@starkgroup.com');
      expect(notifyCount, 1);

      storage.clearSession();
      expect(storage.hasToken, false);
      expect(storage.token, null);
      expect(storage.user, null);
      expect(notifyCount, 2);
    });
  });

  group('AuthInterceptor', () {
    test('Attaches Authorization header when token exists', () {
      final storage = TokenStorage();
      storage.saveSession(
        token: 'token-123',
        user: const AuthUser(
          email: 'test@stark.com',
          name: 'Tester',
          role: 'Admin',
        ),
      );

      final interceptor = AuthInterceptor(tokenStorage: storage);
      final options = RequestOptions(path: '/vehicles');
      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['Authorization'], 'Bearer token-123');
    });

    test('Clears session on 401 from protected endpoint', () {
      final storage = TokenStorage();
      storage.saveSession(
        token: 'token-123',
        user: const AuthUser(
          email: 'test@stark.com',
          name: 'Tester',
          role: 'Admin',
        ),
      );

      bool unauthorizedTriggered = false;
      final interceptor = AuthInterceptor(
        tokenStorage: storage,
        onUnauthorized: () {
          unauthorizedTriggered = true;
        },
      );

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/vehicles'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/vehicles'),
          statusCode: 401,
        ),
      );

      interceptor.onError(dioError, ErrorInterceptorHandler());

      expect(storage.hasToken, false);
      expect(unauthorizedTriggered, true);
    });

    test('Does not trigger unauthorized callback on 401 from login endpoint', () {
      final storage = TokenStorage();
      bool unauthorizedTriggered = false;
      final interceptor = AuthInterceptor(
        tokenStorage: storage,
        onUnauthorized: () {
          unauthorizedTriggered = true;
        },
      );

      final dioError = DioException(
        requestOptions: RequestOptions(path: ApiConfig.authLoginEndpoint),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: ApiConfig.authLoginEndpoint),
          statusCode: 401,
        ),
      );

      interceptor.onError(dioError, ErrorInterceptorHandler());

      expect(unauthorizedTriggered, false);
    });
  });

  group('AuthNotifier', () {
    test('Performs login successfully and updates state', () async {
      final fakeApi = FakeAuthApiService();
      final storage = TokenStorage();
      final repo = AuthRepository(fakeApi, storage);
      final notifier = AuthNotifier(repo, storage);

      expect(notifier.isAuthenticated, false);

      final success = await notifier.login('admin@stark.com', 'pass123');

      expect(success, true);
      expect(notifier.isAuthenticated, true);
      expect(notifier.userName, 'Fleet Admin');
      expect(notifier.errorMessage, null);

      notifier.logout();
      expect(notifier.isAuthenticated, false);
    });

    test('Handles login failure cleanly without crashing', () async {
      final fakeApi = FakeAuthApiService()..shouldFail = true;
      final storage = TokenStorage();
      final repo = AuthRepository(fakeApi, storage);
      final notifier = AuthNotifier(repo, storage);

      final success = await notifier.login('bad@stark.com', 'wrongpass');

      expect(success, false);
      expect(notifier.isAuthenticated, false);
      expect(notifier.errorMessage, contains('Invalid email or password'));
    });
  });
}
