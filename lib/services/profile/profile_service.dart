import 'dart:convert';
import '../../constants/api_constants.dart';
import '../api/api_service.dart';

class ProfileApiService {
  static final ApiClient _apiClient = ApiClient();

  // Get user profile data from API with auto-refresh retry
  static Future<Map<String, dynamic>> getProfile(String jwtToken) async {
    try {
      final response = await _apiClient.get(
        ApiUrls.profileDetails,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        return {'success': true, 'data': responseData};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Profile tidak ditemukan'};
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error koneksi: ${e.toString()}'};
    }
  }

  // Update user profile data to API with auto-refresh retry
  static Future<Map<String, dynamic>> updateProfile(
    String jwtToken,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiUrls.profileDetails,
        body: profileData,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': 'Gagal update profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error koneksi: ${e.toString()}'};
    }
  }
}
