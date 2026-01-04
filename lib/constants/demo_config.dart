/// Demo Mode Configuration
/// Set to true untuk menjalankan UI/UX tanpa Firebase (hardcoded data)
/// Set to false untuk production dengan Firebase
const bool DEMO_MODE = true;

/// Demo user data untuk mode demo
class DemoData {
  static const String demoEmail = 'demo@paradise.com';
  static const String demoPassword = 'Demo123!';
  static const String demoName = 'Paradise User';
  static const String demoToken = 'demo_token_12345';
}
