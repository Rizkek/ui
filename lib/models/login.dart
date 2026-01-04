class LoginCredentials {
  final String email;
  final String password;
  final bool rememberMe;

  LoginCredentials({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  // Validation methods
  String? validateEmail() {
    if (email.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword() {
    if (password.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  bool get isValid {
    return validateEmail() == null && validatePassword() == null;
  }

  // Convert to JSON for API calls if needed
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'rememberMe': rememberMe};
  }

  // Copy with method for immutability
  LoginCredentials copyWith({
    String? email,
    String? password,
    bool? rememberMe,
  }) {
    return LoginCredentials(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  @override
  String toString() {
    return 'LoginCredentials(email: $email, rememberMe: $rememberMe)';
  }
}

class LoginUser {
  final String uid;
  final String email;
  final String? displayName;
  final String token;
  final String? refreshToken;
  final DateTime loginTime;
  final bool? isVerified;
  final String? gender;
  final int? age;
  final String role; // 'parent' or 'child'

  LoginUser({
    required this.uid,
    required this.email,
    this.displayName,
    required this.token,
    this.refreshToken,
    required this.loginTime,
    this.isVerified,
    this.gender,
    this.age,
    this.role = 'child',
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'token': token,
      'refreshToken': refreshToken,
      'loginTime': loginTime.toIso8601String(),
      'isVerified': isVerified,
      'gender': gender,
      'age': age,
      'role': role,
    };
  }

  // Create from JSON
  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      token: json['token'],
      refreshToken: json['refreshToken'],
      loginTime: DateTime.parse(json['loginTime']),
      isVerified: json['isVerified'],
      gender: json['gender'],
      age: json['age'],
      role: json['role'] ?? 'child',
    );
  }

  @override
  String toString() {
    return 'LoginUser(uid: $uid, email: $email, role: $role, displayName: $displayName)';
  }
}
