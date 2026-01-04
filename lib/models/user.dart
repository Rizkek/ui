class User {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String gender;
  final DateTime birthdate;
  final bool acceptTerms;
  final String role; // 'parent' or 'child'

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.gender,
    required this.birthdate,
    required this.acceptTerms,
    this.role = 'child',
  });

  // Calculate age from birthdate
  int get age {
    final now = DateTime.now();
    int calculatedAge = now.year - birthdate.year;
    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  // Convert gender from Indonesian to English
  String get genderInEnglish {
    return gender == 'Laki-laki' ? 'male' : 'female';
  }

  // Validation methods
  String? validateName() {
    if (name.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (name.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }

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
    if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      return 'Password harus mengandung huruf besar, kecil, dan angka';
    }
    return null;
  }

  String? validateGender() {
    if (gender.isEmpty) {
      return 'Pilih jenis kelamin';
    }
    return null;
  }

  String? validateAcceptTerms() {
    if (!acceptTerms) {
      return 'Anda harus menyetujui syarat dan ketentuan';
    }
    return null;
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'gender': genderInEnglish,
      'age': age,
      'acceptTerms': acceptTerms,
      'role': role,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      gender: json['gender'] == 'male' ? 'Laki-laki' : 'Perempuan',
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'])
          : DateTime.now(),
      acceptTerms: json['acceptTerms'] ?? false,
      role: json['role'] ?? 'child',
    );
  }

  // Copy with method for immutability
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? gender,
    DateTime? birthdate,
    bool? acceptTerms,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      role: role ?? this.role,
    );
  }
}
