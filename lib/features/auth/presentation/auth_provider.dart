import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication state model and notifier for the mock session.
class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _userEmail = '';
  String _userName = 'Fleet Admin';
  String _userRole = 'Fleet Administrator';

  bool get isAuthenticated => _isAuthenticated;
  String get userEmail => _userEmail;
  String get userName => _userName;
  String get userRole => _userRole;

  /// Simulates a successful login.
  void login(String email, String password) {
    _isAuthenticated = true;
    _userEmail = email.trim();
    final namePart = email.split('@').first;
    _userName = namePart.isNotEmpty
        ? namePart[0].toUpperCase() + namePart.substring(1)
        : 'Fleet Admin';
    _userRole = 'Fleet Administrator';
    notifyListeners();
  }

  /// Terminates the current session and redirects to login.
  void logout() {
    _isAuthenticated = false;
    _userEmail = '';
    _userName = '';
    _userRole = '';
    notifyListeners();
  }
}

/// Global provider exposing the authentication state and actions.
final authProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});

