import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/auth_models.dart';

/// Storage abstraction managing the active JWT session and user credentials.
/// Implemented as a ChangeNotifier so listeners are notified immediately upon session expiry.
class TokenStorage extends ChangeNotifier {
  String? _token;
  AuthUser? _user;

  String? get token => _token;
  AuthUser? get user => _user;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Stores authentication session tokens and user metadata.
  void saveSession({required String token, required AuthUser user}) {
    _token = token;
    _user = user;
    notifyListeners();
  }

  /// Clears active JWT session and resets authentication state.
  void clearSession() {
    _token = null;
    _user = null;
    notifyListeners();
  }
}

/// Global provider for the shared TokenStorage instance.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

