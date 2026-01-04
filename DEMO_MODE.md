# Demo Mode - Paradise App

## 🎯 Status: DEMO MODE AKTIF

Aplikasi Paradise saat ini berjalan dalam **DEMO MODE** untuk menampilkan UI/UX tanpa memerlukan konfigurasi Firebase.

## 🔑 Demo Credentials

Gunakan kredensial berikut untuk login di demo mode:

- **Email**: Apa saja (format email valid)
- **Password**: Minimal 6 karakter

Atau gunakan kredensial demo yang sudah disediakan:

- **Email**: `demo@paradise.com`
- **Password**: `Demo123!`

## ⚙️ Mengaktifkan/Menonaktifkan Demo Mode

Edit file `lib/constants/demo_config.dart`:

```dart
// Demo Mode ON - UI/UX hardcoded tanpa Firebase
const bool DEMO_MODE = true;

// Production Mode - Gunakan Firebase dan Backend API
const bool DEMO_MODE = false;
```

## 📋 Fitur Demo Mode

### ✅ Yang Berfungsi

- ✅ Splash Screen
- ✅ Onboarding Screen
- ✅ Login Screen (hardcoded validation)
- ✅ Register Screen (hardcoded validation)
- ✅ Dashboard/Home Screen
- ✅ Profile Screen
- ✅ Settings Screen
- ✅ Semua UI/UX Components

### ❌ Yang Tidak Berfungsi

- ❌ Firebase Authentication
- ❌ Backend API Calls
- ❌ Real Data dari Server
- ❌ Push Notifications (requires Firebase)
- ❌ Data Persistence (tidak simpan ke database)
- ❌ NSFW Detection (requires backend)
- ❌ Screen Monitoring (requires native services)

## 🚀 Langkah untuk Production Mode

Untuk menggunakan mode production dengan Firebase dan Backend:

1. **Setup Firebase Paradise**

   ```bash
   flutterfire configure
   ```

2. **Update google-services.json**

   - Download dari Firebase Console Paradise
   - Replace file di `android/app/google-services.json`

3. **Update firebase_options.dart**

   - Akan ter-generate otomatis dari `flutterfire configure`

4. **Matikan Demo Mode**

   ```dart
   // Di lib/constants/demo_config.dart
   const bool DEMO_MODE = false;
   ```

5. **Uncomment Firebase imports di main.dart**

   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'firebase_options.dart';
   import 'services/notifications/notification_service.dart';
   ```

6. **Restore Firebase initialization**
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   await NotificationService().initialize();
   ```

## 📝 Catatan Penting

- Demo mode hanya untuk preview UI/UX
- Tidak ada data yang disimpan secara permanen
- Semua interaksi adalah simulasi
- Backend API tidak dipanggil
- Cocok untuk presentasi dan development UI

---

_Last Updated: 29 December 2025_
