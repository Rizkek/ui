# Paradise App

Paradise Flutter mobile application project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## API Configuration

This project uses a centralized API configuration system similar to environment variables in React/Next.js.

### Current Setup

- Base URL is configured in `lib/constants/api_constants.dart`
- Default base URL: `http://localhost:3000`
- API endpoints are defined as constants for easy maintenance

### Usage

```dart
import '../constants/api_constants.dart';

// Use predefined URLs
final response = await http.post(Uri.parse(ApiUrls.profileDetails));

// Or use endpoints directly
final url = '$baseUrl${ApiEndpoints.profileDetails}';
```

### Changing API URL

To change the API base URL, simply modify the `baseUrl` constant in `lib/constants/api_constants.dart`:

```dart
const String baseUrl = 'https://your-production-api.com';
```

### Future Enhancement (Optional)

If you want to use `.env` files like in React/Next.js:

1. Add `flutter_dotenv` package to `pubspec.yaml`
2. Uncomment the dotenv import in `api_constants.dart`
3. Update the baseUrl to use environment variables
4. Copy `.env.example` to `.env` and modify as needed

```dart
// In api_constants.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
const String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000';
```

5. Load environment variables in `main.dart`:

```dart
void main() async {
  await dotenv.load(fileName: ".env");
  // ... rest of your code
}
```
