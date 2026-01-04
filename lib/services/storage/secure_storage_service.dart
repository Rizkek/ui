// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../models/login.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();

  // Keys for storage
  static const _keyUser = 'user_data';
  static const _keyToken = 'jwt_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyLoginTime = 'login_time';

  // Save user data after login
  static Future<void> saveUserData(LoginUser user) async {
    try {
      await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));
      await _storage.write(key: _keyToken, value: user.token);
      if (user.refreshToken != null) {
        await _storage.write(key: _keyRefreshToken, value: user.refreshToken!);
      }
      await _storage.write(key: _keyLoginTime, value: user.loginTime.toIso8601String());
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  // Get stored user data
  static Future<LoginUser?> getUserData() async {
    try {
      final userData = await _storage.read(key: _keyUser);
      if (userData != null) {
        final Map<String, dynamic> userJson = jsonDecode(userData);
        return LoginUser.fromJson(userJson);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get stored JWT token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Update token (for refresh scenarios)
  static Future<void> updateToken(String newToken) async {
    try {
      await _storage.write(key: _keyToken, value: newToken);
      await _storage.write(key: _keyLoginTime, value: DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to update token: $e');
    }
  }

  // Save refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    } catch (e) {
      throw Exception('Failed to save refresh token: $e');
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final userData = await getUserData();
      return token != null && userData != null;
    } catch (e) {
      return false;
    }
  }

  // Check if token is expired (optional, you can implement based on your needs)
  static Future<bool> isTokenExpired() async {
    try {
      final loginTimeStr = await _storage.read(key: _keyLoginTime);
      if (loginTimeStr == null) return true;

      final loginTime = DateTime.parse(loginTimeStr);
      final now = DateTime.now();
      
      // Firebase tokens expire after 1 hour
      final difference = now.difference(loginTime).inHours;
      return difference >= 1;
    } catch (e) {
      return true; // Assume expired if we can't check
    }
  }

  // Clear all stored data (logout)
  static Future<void> clearAllData() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  // Clear all storage (for debugging)
  static Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to delete all data: $e');
    }
  }

  // Get all stored keys (for debugging)
  static Future<Map<String, String>> getAllData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      print('Error getting all data: $e');
      return {};
    }
  }

  // Save daily breakdown data for 7 days statistics
  static Future<void> saveDailyBreakdown(List<Map<String, dynamic>> dailyBreakdown) async {
    try {
      await _storage.write(key: 'daily_breakdown_7days', value: jsonEncode(dailyBreakdown));
      // Save timestamp to track when data was saved
      await _storage.write(key: 'daily_breakdown_timestamp', value: DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to save daily breakdown: $e');
    }
  }

  // Get daily breakdown data
  static Future<List<Map<String, dynamic>>?> getDailyBreakdown() async {
    try {
      final data = await _storage.read(key: 'daily_breakdown_7days');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.map((item) => item as Map<String, dynamic>).toList();
      }
      return null;
    } catch (e) {
      print('Error getting daily breakdown: $e');
      return null;
    }
  }

  // Update only displayName field inside stored user_data JSON and legacy key
  static Future<void> updateDisplayName(String newName) async {
    try {
      final userData = await _storage.read(key: _keyUser);
      if (userData != null) {
        final Map<String, dynamic> jsonObj = jsonDecode(userData);
        jsonObj['displayName'] = newName;
        await _storage.write(key: _keyUser, value: jsonEncode(jsonObj));
      }
      // also write legacy/plain key to keep other parts compatible if used elsewhere
      await _storage.write(key: 'display_name', value: newName);
    } catch (e) {
      throw Exception('Failed to update display name: $e');
    }
  }
}