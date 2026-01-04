import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../storage/secure_storage_service.dart';
import '../../models/login.dart';

/// Service untuk handle automatic token refresh menggunakan Firebase
class TokenRefreshService {
  static bool _isRefreshing = false;

  /// Refresh Firebase JWT token menggunakan refresh token
  /// Returns: New JWT token if success, null if failed
  static Future<String?> refreshToken() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      print('Token refresh already in progress, waiting...');
      // Wait for ongoing refresh to complete
      int attempts = 0;
      while (_isRefreshing && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      // Return current token after waiting
      return await SecureStorageService.getToken();
    }

    _isRefreshing = true;

    try {
      print('🔄 Attempting to refresh Firebase token...');

      // Get current Firebase user
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        print('❌ No Firebase user found, cannot refresh token');
        return null;
      }

      // Force refresh the token (this uses Firebase refresh token internally)
      final newToken = await currentUser.getIdToken(true); // true = force refresh
      
      if (newToken == null) {
        print('❌ Failed to get new token from Firebase');
        return null;
      }

      print('✅ Successfully refreshed Firebase token');

      // Get refresh token (Firebase manages this automatically)
      final refreshToken = currentUser.refreshToken;

      // Update stored token
      await SecureStorageService.updateToken(newToken);

      // Update login time to reset expiry check
      final userData = await SecureStorageService.getUserData();
      if (userData != null) {
        // Create updated user with new tokens and login time
        final updatedUser = LoginUser(
          uid: userData.uid,
          email: userData.email,
          displayName: userData.displayName,
          token: newToken,
          refreshToken: refreshToken,
          loginTime: DateTime.now(), // Reset login time
          isVerified: userData.isVerified,
          gender: userData.gender,
          age: userData.age,
        );
        
        await SecureStorageService.saveUserData(updatedUser);
        print('✅ Updated user data with new token and timestamp');
      }

      return newToken;
    } catch (e) {
      print('❌ Error refreshing token: $e');
      
      // Check if error is due to invalid refresh token
      if (e.toString().contains('invalid-credential') ||
          e.toString().contains('user-token-expired') ||
          e.toString().contains('user-disabled')) {
        print('🚫 Refresh token is invalid or expired');
        return null;
      }
      
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Check if we should attempt token refresh
  /// Returns true if token is expired but we have a Firebase user
  static Future<bool> shouldRefreshToken() async {
    try {
      // Check if token is expired based on timestamp
      final isExpired = await SecureStorageService.isTokenExpired();
      if (!isExpired) return false;

      // Check if we have a Firebase user (means we can refresh)
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      return currentUser != null;
    } catch (e) {
      print('Error checking if should refresh token: $e');
      return false;
    }
  }

  /// Get valid token - automatically refresh if expired
  /// Returns: Valid token or null if refresh failed
  static Future<String?> getValidToken() async {
    try {
      // First try to get existing token
      final token = await SecureStorageService.getToken();
      if (token == null) return null;

      // Check if token is expired
      final isExpired = await SecureStorageService.isTokenExpired();
      
      if (!isExpired) {
        print('✅ Token is still valid');
        return token;
      }

      print('⏰ Token is expired, attempting refresh...');
      
      // Try to refresh token
      final newToken = await refreshToken();
      
      if (newToken != null) {
        print('✅ Token refreshed successfully');
        return newToken;
      }

      print('❌ Token refresh failed');
      return null;
    } catch (e) {
      print('Error getting valid token: $e');
      return null;
    }
  }

  /// Force logout - clear all data including Firebase session
  static Future<void> forceLogout() async {
    try {
      print('🚪 Force logout - clearing all data...');
      
      // Sign out from Firebase
      await firebase_auth.FirebaseAuth.instance.signOut();
      
      // Clear secure storage
      await SecureStorageService.clearAllData();
      
      print('✅ Successfully logged out and cleared all data');
    } catch (e) {
      print('Error during force logout: $e');
      // Force clear even if Firebase logout fails
      await SecureStorageService.clearAllData();
    }
  }
}
