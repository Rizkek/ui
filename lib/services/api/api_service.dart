import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controllers/login_controller.dart';
import '../storage/secure_storage_service.dart';
import 'token_refresh_service.dart';

/// Centralized API client with automatic token refresh and retry logic
///
/// This class eliminates duplicate retry logic across services by providing
/// a unified interface for making HTTP requests with automatic 401 handling.
/// Also handles session management (logout & redirect) when token refresh fails.
class ApiClient {
  static bool _isLoggingOut = false;

  /// Makes a GET request with automatic retry on 401 errors
  ///
  /// [url] - The endpoint URL
  /// [requiresAuth] - Whether JWT token is required (default: true)
  ///
  /// Returns the http.Response object
  /// Throws exception if request fails after retry
  Future<http.Response> get(String url, {bool requiresAuth = true}) async {
    return _makeRequestWithRetry(
      () => _makeGetRequest(url, requiresAuth),
      requiresAuth,
    );
  }

  /// Makes a POST request with automatic retry on 401 errors
  ///
  /// [url] - The endpoint URL
  /// [body] - Request body (will be JSON encoded)
  /// [requiresAuth] - Whether JWT token is required (default: true)
  ///
  /// Returns the http.Response object
  /// Throws exception if request fails after retry
  Future<http.Response> post(
    String url, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    return _makeRequestWithRetry(
      () => _makePostRequest(url, body, requiresAuth),
      requiresAuth,
    );
  }

  /// Makes a PUT request with automatic retry on 401 errors
  ///
  /// [url] - The endpoint URL
  /// [body] - Request body (will be JSON encoded)
  /// [requiresAuth] - Whether JWT token is required (default: true)
  ///
  /// Returns the http.Response object
  /// Throws exception if request fails after retry
  Future<http.Response> put(
    String url, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    return _makeRequestWithRetry(
      () => _makePutRequest(url, body, requiresAuth),
      requiresAuth,
    );
  }

  /// Makes a DELETE request with automatic retry on 401 errors
  ///
  /// [url] - The endpoint URL
  /// [requiresAuth] - Whether JWT token is required (default: true)
  ///
  /// Returns the http.Response object
  /// Throws exception if request fails after retry
  Future<http.Response> delete(String url, {bool requiresAuth = true}) async {
    return _makeRequestWithRetry(
      () => _makeDeleteRequest(url, requiresAuth),
      requiresAuth,
    );
  }

  /// Core retry logic wrapper
  ///
  /// Attempts the request, and if it returns 401, tries to refresh token
  /// and retry once. If still 401 after retry, forces logout.
  Future<http.Response> _makeRequestWithRetry(
    Future<http.Response> Function() requestFunction,
    bool requiresAuth,
  ) async {
    // First attempt
    http.Response response = await requestFunction();

    // If 401 and requires auth, try to refresh and retry
    if (response.statusCode == 401 && requiresAuth) {
      bool shouldRetry = await _handleUnauthorizedWithRefresh();

      if (shouldRetry) {
        // Retry the request with new token
        response = await requestFunction();

        // If still 401 after retry, already handled by _handleUnauthorizedWithRefresh
      }
    }

    return response;
  }

  /// Internal GET request implementation
  Future<http.Response> _makeGetRequest(String url, bool requiresAuth) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await SecureStorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return await http.get(Uri.parse(url), headers: headers);
  }

  /// Internal POST request implementation
  Future<http.Response> _makePostRequest(
    String url,
    Map<String, dynamic> body,
    bool requiresAuth,
  ) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await SecureStorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
  }

  /// Internal PUT request implementation
  Future<http.Response> _makePutRequest(
    String url,
    Map<String, dynamic> body,
    bool requiresAuth,
  ) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await SecureStorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
  }

  /// Internal DELETE request implementation
  Future<http.Response> _makeDeleteRequest(
    String url,
    bool requiresAuth,
  ) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await SecureStorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return await http.delete(Uri.parse(url), headers: headers);
  }

  // ============================================================================
  // 401 Error Handling & Session Management (from auth_interceptor_service.dart)
  // ============================================================================

  /// Handle 401 error dengan automatic token refresh
  /// Returns: true jika token berhasil di-refresh, false jika harus logout
  Future<bool> _handleUnauthorizedWithRefresh({String? customMessage}) async {
    print('🔑 Handling 401 error - attempting token refresh...');

    try {
      // Try to refresh token first
      final newToken = await TokenRefreshService.refreshToken();

      if (newToken != null) {
        print('✅ Token refreshed successfully, can retry request');
        return true; // Token refreshed, caller should retry request
      }

      print('❌ Token refresh failed, forcing logout...');

      // If refresh failed, force logout
      await _forceLogoutAndRedirect(customMessage);
      return false; // Logout executed
    } catch (e) {
      print('❌ Error during 401 handling: $e');
      await _forceLogoutAndRedirect(customMessage);
      return false;
    }
  }

  /// Force logout and redirect to login
  Future<void> _forceLogoutAndRedirect(String? customMessage) async {
    // Prevent multiple simultaneous logout calls
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      // Force logout dengan clear semua data
      await TokenRefreshService.forceLogout();

      // Show message
      final message =
          customMessage ?? 'Sesi Anda telah berakhir. Silakan login kembali.';

      if (Get.isRegistered<LoginController>()) {
        await Get.find<LoginController>().logout();
      }

      // Redirect ke login
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');

        // Show snackbar after navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar(
            'Sesi Berakhir',
            message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFF59E0B),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.lock_clock, color: Colors.white),
          );
        });
      }
    } catch (e) {
      print('Error handling unauthorized: $e');
    } finally {
      _isLoggingOut = false;
    }
  }
}
