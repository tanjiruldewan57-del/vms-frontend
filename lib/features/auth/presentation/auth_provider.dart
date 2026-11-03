import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

/// Authentication state model and notifier managing live session state and notifications.
class AuthNotifier extends ChangeNotifier {
  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  bool _isLoading = false;
  String? _errorMessage;

  AuthNotifier(this._repository, this._tokenStorage) {
    _tokenStorage.addListener(_handleStorageChange);
  }

  @override
  void dispose() {
    _tokenStorage.removeListener(_handleStorageChange);
    super.dispose();
  }

  void _handleStorageChange() {
    notifyListeners();
  }

  bool get isAuthenticated => _repository.isAuthenticated;
  AuthUser? get currentUser => _repository.currentUser;
  String get userEmail => _repository.currentUser?.email ?? '';

  String get userName {
    final user = _repository.currentUser;
    if (user != null && user.name.isNotEmpty) {
      return user.name;
    }
    return 'Fleet User';
  }

  String get userRole {
    final user = _repository.currentUser;
    if (user != null && user.role.isNotEmpty) {
      return user.role;
    }
    return 'Fleet Administrator';
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Authenticates with Spring Boot backend via AuthRepository.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.login(email.trim(), password);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'An unexpected authentication error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Clears active error message state.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Terminates the current session, clearing storage and notifying navigation guards.
  void logout() {
    _errorMessage = null;
    _repository.logout();
    notifyListeners();
  }
}

/// Global provider exposing the authentication state and actions.
final authProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthNotifier(repository, tokenStorage);
});
