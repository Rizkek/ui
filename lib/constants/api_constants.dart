// API Configuration
// For now using hardcoded value, but can be easily changed to use environment variables
// If you want to use .env file, add flutter_dotenv package and uncomment the import below
// import 'package:flutter_dotenv/flutter_dotenv.dart';

const String baseUrl = 'http://192.168.100.12:3000'; // String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:3000');

// To use with flutter_dotenv:
// const String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

// API Endpoints
class ApiEndpoints {
  static const String profileDetails = '/api/profile';
  static const String login = '/api/auth/login';
  static const String register = '/api/profile/details';
  static const String statistics = '/api/statistics';
  static const String detectNsfw = '/api/detectnsfw';
  // Add more endpoints as needed
}

// Full API URLs
class ApiUrls {
  static String get profileDetails => '$baseUrl${ApiEndpoints.profileDetails}';
  static String get login => '$baseUrl${ApiEndpoints.login}';
  static String get register => '$baseUrl${ApiEndpoints.register}';
  static String get detectNsfw => '$baseUrl${ApiEndpoints.detectNsfw}';
  static String statistics({required String period}) => '$baseUrl${ApiEndpoints.statistics}?period=$period';
}