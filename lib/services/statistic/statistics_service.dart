import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../api/api_service.dart';

class StatisticsService {
  static final ApiClient _apiClient = ApiClient();
  static const String _cacheKeyToday = 'statistics_today_cache';
  static const String _cacheKey7Days = 'statistics_7days_cache';
  static const String _cacheStamp7Days = 'statistics_7days_cached_date';

  // Returns cached JSON if exists; otherwise null
  static Future<Map<String, dynamic>?> getCachedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKeyToday);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Force fetch from API using Bearer token with auto-refresh
  static Future<Map<String, dynamic>?> fetchToday() async {
    return await _fetchWithRetry(
      endpoint: ApiUrls.statistics(period: 'today'),
      cacheKey: _cacheKeyToday,
    );
  }

  // Helper method untuk fetch dengan automatic token refresh & retry
  static Future<Map<String, dynamic>?> _fetchWithRetry({
    required String endpoint,
    String? cacheKey,
  }) async {
    final res = await _apiClient.get(endpoint, requiresAuth: true);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;

      // Cache if cacheKey provided
      if (cacheKey != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(decoded));
      }

      return decoded;
    }

    return null;
  }

  // Get statistics preferring cache; set forceRefresh to bypass cache.
  static Future<Map<String, dynamic>?> getToday({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await getCachedToday();
      if (cached != null) return cached;
    }
    return fetchToday();
  }

  // 7 days helpers
  static Future<Map<String, dynamic>?> getCached7Days() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey7Days);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetch7Days() async {
    final result = await _fetchWithRetry(
      endpoint: ApiUrls.statistics(period: '7days'),
      cacheKey: _cacheKey7Days,
    );

    if (result != null) {
      // Save timestamp
      final prefs = await SharedPreferences.getInstance();
      final todayStamp = _todayStamp();
      await prefs.setString(_cacheStamp7Days, todayStamp);

      // Also save dailyBreakdown to secure storage for easy access
      final stats = result['statistics'] as Map<String, dynamic>?;
      if (stats != null) {
        final dailyBreakdown = stats['dailyBreakdown'] as List?;
        if (dailyBreakdown != null) {
          final List<Map<String, dynamic>> dailyList = dailyBreakdown
              .map((item) => item as Map<String, dynamic>)
              .toList();
          await SecureStorageService.saveDailyBreakdown(dailyList);
        }
      }
    }

    return result;
  }

  static Future<Map<String, dynamic>?> get7Days() async {
    final prefs = await SharedPreferences.getInstance();
    final stamp = prefs.getString(_cacheStamp7Days);
    final today = _todayStamp();
    if (stamp == today) {
      final cached = await getCached7Days();
      if (cached != null) return cached;
    }
    return fetch7Days();
  }

  static String _todayStamp() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}$mm$dd';
  }

  // Get dailyBreakdown directly from secure storage
  static Future<List<Map<String, dynamic>>?> getDailyBreakdown() async {
    return await SecureStorageService.getDailyBreakdown();
  }
}
