import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/login.dart';
import '../services/storage/secure_storage_service.dart';
import '../services/profile/profile_service.dart';
import '../services/api/token_refresh_service.dart';
import '../constants/demo_config.dart';

enum LoginState { idle, loading, success, error }

class LoginController {
  LoginState _state = LoginState.idle;
  String? _errorMessage;
  LoginUser? _currentUser;

  // Getters
  LoginState get state => _state;
  String? get errorMessage => _errorMessage;
  LoginUser? get currentUser => _currentUser;

  // State management
  void _setState(LoginState newState) {
    _state = newState;
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(LoginState.error);
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Validation
  bool validateCredentials(LoginCredentials credentials) {
    _clearError();

    final emailError = credentials.validateEmail();
    if (emailError != null) {
      _setError(emailError);
      return false;
    }

    final passwordError = credentials.validatePassword();
    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    return true;
  }

  // Firebase login
  Future<firebase_auth.User?> _loginWithFirebase(
    LoginCredentials credentials,
  ) async {
    try {
      final credential = await firebase_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: credentials.email.trim(),
            password: credentials.password,
          );

      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar.';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid.';
          break;
        case 'user-disabled':
          errorMessage = 'Akun ini telah dinonaktifkan.';
          break;
        case 'too-many-requests':
          errorMessage = 'Terlalu banyak percobaan. Coba lagi nanti.';
          break;
        case 'invalid-credential':
          errorMessage = 'Email atau password salah.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
      throw Exception(errorMessage);
    }
  }

  // Main login method
  Future<LoginResult> login(LoginCredentials credentials) async {
    if (!validateCredentials(credentials)) {
      return LoginResult(
        success: false,
        message: _errorMessage ?? 'Validation failed',
        type: LoginResultType.validationError,
      );
    }

    _setState(LoginState.loading);

    try {
      // DEMO MODE: Skip Firebase, use hardcoded data
      if (DEMO_MODE) {
        await Future.delayed(
          const Duration(seconds: 1),
        ); // Simulate network delay

        // Simple role determination for demo:
        // parent@paradise.com -> parent
        // anything else -> child
        final role = credentials.email.startsWith('parent')
            ? 'parent'
            : 'child';

        _currentUser = LoginUser(
          uid: 'demo_uid_123',
          email: credentials.email,
          displayName: DemoData.demoName,
          token: DemoData.demoToken,
          refreshToken: 'demo_refresh_token',
          loginTime: DateTime.now(),
          isVerified: true,
          gender: 'Laki-laki',
          age: 25,
          role: role,
        );

        await SecureStorageService.saveUserData(_currentUser!);

        _setState(LoginState.success);

        return LoginResult(
          success: true,
          message: 'Login berhasil! (Demo Mode)',
          type: LoginResultType.success,
          user: _currentUser,
        );
      }

      // PRODUCTION MODE: Use Firebase
      // Step 1: Login with Firebase
      final firebaseUser = await _loginWithFirebase(credentials);

      if (firebaseUser == null) {
        throw Exception('Failed to login with Firebase');
      }

      // Step 2: Get Firebase JWT token and refresh token
      final idToken = await firebaseUser.getIdToken();
      final refreshToken = firebaseUser.refreshToken;

      if (idToken == null) {
        throw Exception('Failed to get authentication token');
      }

      // Step 3: Get profile data from API
      final profileResult = await ProfileApiService.getProfile(idToken);

      if (!profileResult['success']) {
        throw Exception(
          profileResult['message'] ?? 'Failed to get profile data',
        );
      }

      final profileData = profileResult['data'];

      // Derive display name with graceful fallbacks when backend doesn't return it
      String deriveDisplayName(String email) {
        final prefix = email.split('@').first;
        if (prefix.isEmpty) return 'Pengguna';
        // Simple title-case-ish: split by . _ - and capitalize first token
        final parts = prefix.split(RegExp(r'[._-]+'));
        final first = parts.isNotEmpty ? parts.first : prefix;
        return first.isNotEmpty
            ? first[0].toUpperCase() +
                  (first.length > 1 ? first.substring(1) : '')
            : 'Pengguna';
      }

      final computedDisplayName =
          (profileData['display_name'] as String?)?.trim().isNotEmpty == true
          ? (profileData['display_name'] as String).trim()
          : (firebaseUser.displayName?.trim().isNotEmpty == true
                ? firebaseUser.displayName!.trim()
                : deriveDisplayName(firebaseUser.email ?? credentials.email));

      // Step 4: Create LoginUser object with complete profile data
      _currentUser = LoginUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? credentials.email,
        displayName: computedDisplayName,
        token: idToken,
        refreshToken: refreshToken,
        loginTime: DateTime.now(),
        isVerified: profileData['is_verified'] ?? false,
        gender: profileData['gender'],
        age: profileData['age'],
        role: profileData['role'] ?? 'child', // Fallback to child
      );

      // Step 5: Save to secure storage
      await SecureStorageService.saveUserData(_currentUser!);

      _setState(LoginState.success);

      return LoginResult(
        success: true,
        message: profileData['message'] ?? 'Login berhasil!',
        type: LoginResultType.success,
        user: _currentUser,
      );
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));

      return LoginResult(
        success: false,
        message: _errorMessage ?? 'Terjadi kesalahan tidak dikenal',
        type: LoginResultType.error,
      );
    }
  }

  // Login with explicitly selected role (from UI selection)
  Future<LoginResult> loginWithRole(
    LoginCredentials credentials, {
    required String selectedRole,
  }) async {
    if (!validateCredentials(credentials)) {
      return LoginResult(
        success: false,
        message: _errorMessage ?? 'Validation failed',
        type: LoginResultType.validationError,
      );
    }

    _setState(LoginState.loading);

    try {
      // DEMO MODE: Use selected role instead of auto-detecting
      if (DEMO_MODE) {
        await Future.delayed(
          const Duration(seconds: 1),
        ); // Simulate network delay

        _currentUser = LoginUser(
          uid: 'demo_uid_123',
          email: credentials.email,
          displayName: DemoData.demoName,
          token: DemoData.demoToken,
          refreshToken: 'demo_refresh_token',
          loginTime: DateTime.now(),
          isVerified: true,
          gender: 'Laki-laki',
          age: 25,
          role: selectedRole, // Use the selected role from UI
        );

        await SecureStorageService.saveUserData(_currentUser!);

        _setState(LoginState.success);

        return LoginResult(
          success: true,
          message: 'Login berhasil! (Demo Mode)',
          type: LoginResultType.success,
          user: _currentUser,
        );
      }

      // PRODUCTION MODE: Use Firebase with selected role
      // Step 1: Login with Firebase
      final firebaseUser = await _loginWithFirebase(credentials);

      if (firebaseUser == null) {
        throw Exception('Failed to login with Firebase');
      }

      // Step 2: Get Firebase JWT token and refresh token
      final idToken = await firebaseUser.getIdToken();
      final refreshToken = firebaseUser.refreshToken;

      if (idToken == null) {
        throw Exception('Failed to get authentication token');
      }

      // Step 3: Get profile data from API
      final profileResult = await ProfileApiService.getProfile(idToken);

      if (!profileResult['success']) {
        throw Exception(
          profileResult['message'] ?? 'Failed to get profile data',
        );
      }

      final profileData = profileResult['data'];

      // Derive display name with graceful fallbacks when backend doesn't return it
      String deriveDisplayName(String email) {
        final prefix = email.split('@').first;
        if (prefix.isEmpty) return 'Pengguna';
        // Simple title-case-ish: split by . _ - and capitalize first token
        final parts = prefix.split(RegExp(r'[._-]+'));
        final first = parts.isNotEmpty ? parts.first : prefix;
        return first.isNotEmpty
            ? first[0].toUpperCase() +
                  (first.length > 1 ? first.substring(1) : '')
            : 'Pengguna';
      }

      final computedDisplayName =
          (profileData['display_name'] as String?)?.trim().isNotEmpty == true
          ? (profileData['display_name'] as String).trim()
          : (firebaseUser.displayName?.trim().isNotEmpty == true
                ? firebaseUser.displayName!.trim()
                : deriveDisplayName(firebaseUser.email ?? credentials.email));

      // Step 4: Create LoginUser object with complete profile data
      _currentUser = LoginUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? credentials.email,
        displayName: computedDisplayName,
        token: idToken,
        refreshToken: refreshToken,
        loginTime: DateTime.now(),
        isVerified: profileData['is_verified'] ?? false,
        gender: profileData['gender'],
        age: profileData['age'],
        role: selectedRole, // Use the selected role from UI
      );

      // Step 5: Save to secure storage
      await SecureStorageService.saveUserData(_currentUser!);

      _setState(LoginState.success);

      return LoginResult(
        success: true,
        message: profileData['message'] ?? 'Login berhasil!',
        type: LoginResultType.success,
        user: _currentUser,
      );
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));

      return LoginResult(
        success: false,
        message: _errorMessage ?? 'Terjadi kesalahan tidak dikenal',
        type: LoginResultType.error,
      );
    }
  }

  // Check if user is already logged in
  Future<LoginResult> checkLoginStatus() async {
    try {
      final isLoggedIn = await SecureStorageService.isLoggedIn();

      if (!isLoggedIn) {
        return LoginResult(
          success: false,
          message: 'User not logged in',
          type: LoginResultType.notLoggedIn,
        );
      }

      // DEMO MODE: Check directly from storage without Firebase
      if (DEMO_MODE) {
        _currentUser = await SecureStorageService.getUserData();
        if (_currentUser != null) {
          _setState(LoginState.success);
          return LoginResult(
            success: true,
            message: 'User is logged in (Demo)',
            type: LoginResultType.success,
            user: _currentUser,
          );
        }
      }

      // PRODUCTION CHECKS

      // Check if Firebase user exists (refresh token check)
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        // No Firebase session, logout
        print('❌ No Firebase user found, logging out...');
        await logout();
        return LoginResult(
          success: false,
          message: 'Session expired',
          type: LoginResultType.sessionExpired,
        );
      }

      // Check if JWT token is expired (timestamp-based)
      final isExpired = await SecureStorageService.isTokenExpired();
      if (isExpired) {
        print('⏰ JWT token expired based on timestamp, attempting refresh...');

        // Try to refresh token using Firebase refresh token
        final newToken = await TokenRefreshService.refreshToken();

        if (newToken == null) {
          // Refresh failed, Firebase session might be invalid
          print('❌ Token refresh failed, logging out...');
          await logout();
          return LoginResult(
            success: false,
            message: 'Session expired',
            type: LoginResultType.sessionExpired,
          );
        }

        print('✅ Token refreshed successfully on app startup');
      }

      // Get user data from storage
      _currentUser = await SecureStorageService.getUserData();

      if (_currentUser != null) {
        _setState(LoginState.success);
        return LoginResult(
          success: true,
          message: 'User is logged in',
          type: LoginResultType.success,
          user: _currentUser,
        );
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      print('Error checking login status: $e');
      await logout(); // Clear corrupted data
      return LoginResult(
        success: false,
        message: 'Failed to check login status',
        type: LoginResultType.error,
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (!DEMO_MODE) {
        // Sign out from Firebase
        await firebase_auth.FirebaseAuth.instance.signOut();
      }

      // Clear secure storage
      await SecureStorageService.clearAllData();

      // Reset state
      _currentUser = null;
      _setState(LoginState.idle);
      _clearError();
    } catch (e) {
      print('Error during logout: $e');
      // Force clear even if logout fails
      await SecureStorageService.clearAllData();
      _currentUser = null;
      _setState(LoginState.idle);
      _clearError();
    }
  }

  // Reset controller state
  void reset() {
    _state = LoginState.idle;
    _errorMessage = null;
    // Don't clear _currentUser here as it might be needed
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final newToken = await currentUser.getIdToken(true); // Force refresh
        final newRefreshToken = currentUser.refreshToken;

        if (newToken != null) {
          await SecureStorageService.updateToken(newToken);

          // Update current user with new tokens
          if (_currentUser != null) {
            _currentUser = LoginUser(
              uid: _currentUser!.uid,
              email: _currentUser!.email,
              displayName: _currentUser!.displayName,
              token: newToken,
              refreshToken: newRefreshToken,
              loginTime: DateTime.now(),
              isVerified: _currentUser!.isVerified,
              gender: _currentUser!.gender,
              age: _currentUser!.age,
              role: _currentUser!.role,
            );
            await SecureStorageService.saveUserData(_currentUser!);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }
}

// Result classes
enum LoginResultType {
  success,
  validationError,
  error,
  notLoggedIn,
  sessionExpired,
}

class LoginResult {
  final bool success;
  final String message;
  final LoginResultType type;
  final LoginUser? user;

  LoginResult({
    required this.success,
    required this.message,
    required this.type,
    this.user,
  });
}
