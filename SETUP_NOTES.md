# Paradise App - Setup Notes

## 📱 Identitas Aplikasi

Aplikasi ini adalah hasil migrasi dari Reflvy ke Paradise dengan perubahan identitas sebagai berikut:

| Sebelum                    | Sesudah                  |
| -------------------------- | ------------------------ |
| raflefly_front             | paradise_app             |
| RafleFly                   | Paradise                 |
| com.example.raflefly_front | com.example.paradise_app |
| com.reflvy.app             | com.paradise.app         |

## 🔥 Firebase Configuration (PERLU DIUPDATE)

File-file berikut masih menggunakan konfigurasi Firebase Reflvy dan **HARUS** diganti dengan konfigurasi Firebase Paradise:

### 1. Android: `android/app/google-services.json`

- Download file `google-services.json` baru dari Firebase Console Paradise
- Replace file yang ada

### 2. Flutter: `lib/firebase_options.dart`

- Jalankan: `flutterfire configure` dengan project Firebase Paradise
- Atau update manual dengan kredensial Firebase Paradise

### 3. iOS: `ios/Runner/GoogleService-Info.plist` (jika ada)

- Download dari Firebase Console Paradise

## 📁 Struktur File yang Diubah

```
paradise_app/
├── pubspec.yaml                 # name: paradise_app
├── android/
│   ├── app/
│   │   ├── build.gradle.kts     # applicationId & namespace
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   ├── kotlin/com/example/paradise_app/  # package folder
│   │   │   └── res/values/strings.xml
│   │   └── google-services.json  # ⚠️ PERLU UPDATE
├── ios/
│   └── Runner/Info.plist
├── lib/
│   ├── main.dart                # title: 'Paradise'
│   ├── firebase_options.dart    # ⚠️ PERLU UPDATE
│   └── views/
│       └── onboarding_screen.dart
├── web/index.html
├── linux/runner/my_application.cc
└── windows/CMakeLists.txt
```

## 🚀 Langkah Selanjutnya

1. **Setup Firebase Paradise**

   ```bash
   # Install Firebase CLI jika belum
   npm install -g firebase-tools

   # Login ke Firebase
   firebase login

   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Configure Firebase untuk Paradise
   flutterfire configure
   ```

2. **Tambahkan Logo Paradise**

   - Replace `assets/images/` dengan logo Paradise
   - Update `android/app/src/main/res/mipmap-*/` dengan icon launcher baru
   - Update `ios/Runner/Assets.xcassets/AppIcon.appiconset/` dengan icon iOS

3. **Build & Test**
   ```bash
   cd C:\Users\Lenovo\Documents\paradisee\zikri
   flutter pub get
   flutter run
   ```

## 📚 Dokumentasi

Semua dokumentasi teknis tersedia di folder `docs/`:

- `ANDROID_14_15_FIX.md` - Perbaikan untuk Android 14/15
- `BACKEND_ARCHITECTURE_ANALYSIS.md` - Arsitektur Backend
- `FULL_SCREEN_OVERLAY_DESIGN.md` - Desain Overlay Full Screen
- `NSFW_MONITORING_FLOW.md` - Alur Monitoring NSFW
- `OVERLAY_PERMISSION_GUIDE.md` - Panduan Permission Overlay
- Dan lainnya...

## ⚠️ Catatan Penting

- Firebase configuration masih menggunakan project `reflvy-d3e67`
- Perlu membuat project Firebase baru untuk Paradise
- Logo dan icon launcher perlu diganti dengan asset Paradise
- MethodChannel sudah diubah ke `com.paradise.app`

---

_Generated on: 29 December 2025_
