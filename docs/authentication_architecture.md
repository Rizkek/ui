# Authentication Architecture

## Overview

Aplikasi ini memiliki 2 sistem authentication yang terpisah untuk tujuan yang berbeda:

## 🔴 1. Mock Authentication (Development/Testing)

**File terkait:**
- `lib/services/auth_service.dart` - Mock authentication service
- `lib/controllers/auth_controller.dart` - Controller untuk mock auth

**Karakteristik:**
- ✅ Menggunakan hardcoded credentials (admin@example.com / admin123)
- ✅ Data disimpan di SharedPreferences (local only)
- ✅ Dummy data untuk dashboard stats, detection history, notifications
- ✅ Cocok untuk development dan testing UI
- ❌ **TIDAK untuk production!**

**Use Cases:**
- Development UI tanpa backend
- Testing flow aplikasi
- Demo aplikasi
- Unit testing

---

## 🟢 2. Real Authentication (Production)

**File terkait:**
- `lib/controllers/login_controller.dart` - Real authentication controller
- `lib/services/token_refresh_service.dart` - Firebase token management
- `lib/services/api_client.dart` - HTTP client dengan auto-retry
- `lib/services/auth_interceptor_service.dart` - 401 error handling
- `lib/services/secure_storage_service.dart` - Encrypted token storage

**Karakteristik:**
- ✅ Firebase Authentication (real email/password)
- ✅ JWT tokens dengan 1-hour expiry
- ✅ Firebase refresh tokens (never expire)
- ✅ Automatic token refresh on 401 errors
- ✅ Secure encrypted storage (flutter_secure_storage)
- ✅ Real API integration dengan backend

**Authentication Flow:**

```
1. User Login
   └─> Firebase Auth (createUserWithEmailAndPassword)
       └─> Get JWT token (getIdToken)
           └─> Save to SecureStorage
               └─> Navigate to Dashboard

2. API Calls
   └─> ApiClient.get/post/put/delete
       └─> Add Bearer token to header
           └─> If 401 error:
               └─> TokenRefreshService.refreshToken()
                   └─> Firebase getIdToken(true)
                       └─> Retry request with new token
                           └─> If still 401: Force logout

3. Token Expiry Check
   └─> LoginController.checkLoginStatus()
       └─> Check Firebase user exists
           └─> If token expired but Firebase user exists:
               └─> Attempt token refresh
                   └─> Success: Continue session
                   └─> Failed: Logout
```

**API Integration:**

Semua API calls harus menggunakan `ApiClient` untuk mendapatkan:
- Automatic JWT token attachment
- Automatic retry on 401 errors
- Automatic token refresh
- Consistent error handling

**Example Usage:**

```dart
// Statistics Service
final ApiClient _apiClient = ApiClient();

Future<Map<String, dynamic>?> fetchData() async {
  final response = await _apiClient.get(
    'https://api.example.com/statistics',
    requiresAuth: true, // Default: true
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return null;
}
```

---

## Migration Path

Jika ingin migrate dari Mock ke Real Authentication:

1. **Stop using:** `AuthController` & `AuthService`
2. **Start using:** `LoginController` & Firebase auth
3. **Update navigation:** Ganti route ke `/login` yang menggunakan `LoginController`
4. **API calls:** Gunakan `ApiClient` untuk semua HTTP requests
5. **Storage:** Gunakan `SecureStorageService` untuk sensitive data

---

## Files Summary

| File | Purpose | Status |
|------|---------|--------|
| `auth_service.dart` | Mock authentication | Development only ⚠️ |
| `auth_controller.dart` | Mock controller | Development only ⚠️ |
| `login_controller.dart` | Real authentication | Production ✅ |
| `token_refresh_service.dart` | Token management | Production ✅ |
| `api_client.dart` | HTTP client wrapper | Production ✅ |
| `auth_interceptor_service.dart` | 401 handling | Production ✅ |
| `secure_storage_service.dart` | Encrypted storage | Production ✅ |

---

## Refactoring Progress

✅ **Completed:**
- Created `ApiClient` wrapper for centralized HTTP requests
- Eliminated ~200 lines of duplicate retry logic
- Refactored 3 services to use `ApiClient`:
  - `statistics_service.dart` (reduced 56 lines)
  - `profile_api_service.dart` (reduced 109 lines)
  - `register_controller.dart` (reduced 60 lines)
- Added clear documentation for mock vs real auth
- Maintained backward compatibility

🎯 **Benefits:**
- Single source of truth for retry logic
- Easier maintenance (1 file instead of 3+)
- Consistent 401 error handling across all APIs
- Cleaner, more readable service code

---

## Security Notes

⚠️ **Important:**
- JWT tokens expire after 1 hour
- Firebase refresh tokens never expire (unless revoked)
- All tokens stored in encrypted storage (flutter_secure_storage)
- Always use `requiresAuth: true` for protected endpoints
- Never hardcode credentials in production code

🔐 **Best Practices:**
- Check token expiry before making requests
- Handle 401 errors gracefully with automatic refresh
- Clear all tokens on logout
- Use HTTPS for all API calls
- Never log sensitive data (tokens, passwords)
