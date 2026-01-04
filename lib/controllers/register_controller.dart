import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../models/login.dart';
import '../services/storage/secure_storage_service.dart';
import '../constants/api_constants.dart';
import '../constants/demo_config.dart';
import '../services/api/api_service.dart';

enum RegisterState { idle, loading, success, error }

class RegisterController {
  final ApiClient _apiClient = ApiClient();
  RegisterState _state = RegisterState.idle;
  String? _errorMessage;
  User? _registeredUser;

  // Getters
  RegisterState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get registeredUser => _registeredUser;

  // State management
  void _setState(RegisterState newState) {
    _state = newState;
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(RegisterState.error);
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Validation methods
  bool validateUser(User user, String confirmPassword) {
    _clearError();

    // Validate all fields
    final nameError = user.validateName();
    if (nameError != null) {
      _setError(nameError);
      return false;
    }

    final emailError = user.validateEmail();
    if (emailError != null) {
      _setError(emailError);
      return false;
    }

    final passwordError = user.validatePassword();
    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    // Validate password confirmation
    if (confirmPassword != user.password) {
      _setError('Password tidak cocok');
      return false;
    }

    final genderError = user.validateGender();
    if (genderError != null) {
      _setError(genderError);
      return false;
    }

    final termsError = user.validateAcceptTerms();
    if (termsError != null) {
      _setError(termsError);
      return false;
    }

    return true;
  }

  // Firebase registration
  Future<firebase_auth.User?> _registerWithFirebase(User user) async {
    try {
      final credential = await firebase_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: user.email.trim(),
            password: user.password,
          );

      // Update the user's display name
      await credential.user?.updateDisplayName(user.name.trim());

      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password terlalu lemah.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email sudah digunakan oleh akun lain.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Registrasi dengan email/password tidak diizinkan.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
      throw Exception(errorMessage);
    }
  }

  // API profile creation with auto-refresh retry
  Future<bool> _createProfile(String token, User user) async {
    try {
      final response = await _apiClient.post(
        ApiUrls.register,
        body: {
          'gender': user.genderInEnglish,
          'age': user.age,
          'role': user.role,
        },
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(
          'Profile creation failed: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error creating profile: $e');
      return false;
    }
  }

  // Main registration method
  Future<RegisterResult> register(User user, String confirmPassword) async {
    if (!validateUser(user, confirmPassword)) {
      return RegisterResult(
        success: false,
        message: _errorMessage ?? 'Validation failed',
        type: RegisterResultType.validationError,
      );
    }

    _setState(RegisterState.loading);

    try {
      // DEMO MODE: Skip Firebase and API, return success
      if (DEMO_MODE) {
        await Future.delayed(
          const Duration(seconds: 1),
        ); // Simulate network delay

        _registeredUser = user.copyWith(id: 'demo_user_123');

        // AUTO LOGIN for Demo: Save LoginUser with correct role to storage
        final loginUser = LoginUser(
          uid: 'demo_user_123',
          email: user.email,
          displayName: user.name,
          token: 'demo_token_123',
          refreshToken: 'demo_refresh_token',
          loginTime: DateTime.now(),
          isVerified: true,
          gender: user.gender,
          age: user.age,
          role: user.role, // Persist the selected role
        );
        await SecureStorageService.saveUserData(loginUser);

        _setState(RegisterState.success);

        return RegisterResult(
          success: true,
          message: 'Registrasi berhasil! (Demo Mode)',
          type: RegisterResultType.success,
          user: _registeredUser,
        );
      }

      // PRODUCTION MODE: Use Firebase and API
      // Step 1: Register with Firebase
      final firebaseUser = await _registerWithFirebase(user);

      if (firebaseUser == null) {
        throw Exception('Failed to create Firebase user');
      }

      // Step 2: Get Firebase JWT token
      final token = await firebaseUser.getIdToken();

      if (token == null) {
        throw Exception('Failed to get authentication token');
      }

      // Step 3: Create profile via API
      final profileCreated = await _createProfile(token, user);

      // Step 4: Auto Login (Save Session)
      final loginUser = LoginUser(
        uid: firebaseUser.uid,
        email: user.email,
        displayName: user.name,
        token: token,
        refreshToken: firebaseUser.refreshToken,
        loginTime: DateTime.now(),
        isVerified: false, // Default for new registration
        gender: user.gender,
        age: user.age,
        role: user.role,
      );
      await SecureStorageService.saveUserData(loginUser);

      if (profileCreated) {
        _registeredUser = user.copyWith(id: firebaseUser.uid);
        _setState(RegisterState.success);

        return RegisterResult(
          success: true,
          message: 'Registrasi berhasil! Profil Anda telah dibuat.',
          type: RegisterResultType.success,
          user: _registeredUser,
        );
      } else {
        // Profile creation failed but user is still registered in Firebase
        _registeredUser = user.copyWith(id: firebaseUser.uid);
        _setState(RegisterState.success);

        return RegisterResult(
          success: true,
          message:
              'Akun berhasil dibuat, tetapi gagal menyimpan profil. Anda tetap bisa login.',
          type: RegisterResultType.partialSuccess,
          user: _registeredUser,
        );
      }
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));

      return RegisterResult(
        success: false,
        message: _errorMessage ?? 'Terjadi kesalahan tidak dikenal',
        type: RegisterResultType.error,
      );
    }
  }

  // Reset controller state
  void reset() {
    _state = RegisterState.idle;
    _errorMessage = null;
    _registeredUser = null;
  }
}

// Result classes
enum RegisterResultType { success, partialSuccess, validationError, error }

class RegisterResult {
  final bool success;
  final String message;
  final RegisterResultType type;
  final User? user;

  RegisterResult({
    required this.success,
    required this.message,
    required this.type,
    this.user,
  });
}
