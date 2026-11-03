import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/token_storage.dart';
import '../domain/auth_models.dart';
import 'auth_api_service.dart';

/// Repository abstracting authentication lifecycle, persistence, and state retrieval.
class AuthRepository {
  final AuthApiService _apiService;
  final TokenStorage _tokenStorage;

  const AuthRepository(this._apiService, this._tokenStorage);

  /// Authenticates credentials with backend and persists the token session.
  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiService.login(
      LoginRequest(
        email: email,
        password: password,
      ),
    );

    _tokenStorage.saveSession(
      token: response.token,
      user: response.user,
    );

    return response;
  }

  /// Terminates the current active session.
  void logout() {
    _tokenStorage.clearSession();
  }

  /// Checks whether an authenticated session exists.
  bool get isAuthenticated => _tokenStorage.hasToken;

  /// Retrieves the current active user profile.
  AuthUser? get currentUser => _tokenStorage.user;

  /// Retrieves the active JWT token string.
  String? get token => _tokenStorage.token;
}

/// Global provider for AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepository(apiService, tokenStorage);
});

