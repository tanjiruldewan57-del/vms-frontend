/// Represents an authenticated user profile in the Stark Group VMS portal.
class AuthUser {
  final String email;
  final String name;
  final String role;

  const AuthUser({
    required this.email,
    required this.name,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'Fleet User',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'role': role,
    };
  }
}

/// Request DTO for Spring Boot authentication endpoint `POST /api/v1/auth/login`.
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email.trim(),
      'password': password,
    };
  }
}

/// Success payload received from Spring Boot authentication endpoint.
/// Expected response: { "token": "<jwt_token>", "user": { "email": "...", "name": "...", "role": "..." } }
class AuthResponse {
  final String token;
  final AuthUser user;

  const AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return AuthResponse(
      token: json['token'] as String? ?? '',
      user: AuthUser.fromJson(userJson),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'token': token,
      'user': user.toJson(),
    };
  }
}

