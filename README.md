# 🛡️ Paradise Guardian - AI-Powered Content Monitoring App

<div align="center">

![Paradise Guardian](assets/images/logo_paradise.jpg)

**Melindungi Digital Wellness dengan Teknologi AI & Psikologi**

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📋 Daftar Isi

- [Tentang Project](#-tentang-project)
- [Fitur Utama](#-fitur-utama)
- [Arsitektur Aplikasi](#-arsitektur-aplikasi)
- [Tech Stack](#-tech-stack)
- [Struktur Folder](#-struktur-folder)
- [Setup & Instalasi](#-setup--instalasi)
- [Konfigurasi](#-konfigurasi)
- [Dokumentasi Lengkap](#-dokumentasi-lengkap)
- [Kontribusi](#-kontribusi)

---

## 🌟 Tentang Project

**Paradise Guardian** adalah aplikasi mobile monitoring berbasis AI yang dirancang untuk mendeteksi dan mencegah paparan konten pornografi dengan pendekatan **Cognitive Behavioral Therapy (CBT)**. Aplikasi ini membantu pengguna mengendalikan konsumsi konten digital mereka dengan intervensi psikologis otomatis dan dukungan chatbot AI.

### 🎯 Tujuan

- Melindungi pengguna dari konten digital berbahaya
- Memberikan intervensi CBT real-time saat deteksi konten berisiko
- Memberikan kontrol parental untuk orang tua
- Menganalisis tren perilaku digital dengan AI
- Memberikan dukungan konseling melalui chatbot AI

---

## 🌟 Fitur Utama

### 1. **Dual Role System** 👥

- **Mode Anak**: Monitoring aktivitas, deteksi konten, intervensi CBT
- **Mode Orang Tua**: Dashboard monitoring, laporan deteksi, kontrol penuh

### 2. **AI Content Detection** 🤖

- Deteksi otomatis konten pornografi dari aplikasi target (YouTube, Twitter, Instagram, dll)
- Klasifikasi risiko: **Low**, **Medium**, **High**
- Machine Learning model untuk analisis visual real-time
- Background service monitoring berkelanjutan

### 3. **Intervensi CBT Otomatis** 🧠

Setiap deteksi memicu popup intervensi 3 komponen:

- **🧩 Trigger Identification**: Mengenali pemicu perilaku
- **📘 Psychoeducation**: Edukasi risiko dan dampak
- **⚡ Behavioral Activation**: Saran tindakan alternatif

### 4. **Monitoring dari Orang Tua** 👨‍👩‍👧‍👦

- Toggle ON/OFF monitoring di halaman profile anak
- Auto screenshot setiap 5 detik
- Dummy detection popup setiap 10 detik
- Real-time threat notification
- Laporan deteksi komprehensif untuk parent

### 5. **Parental Control Mode** 🔐

- Dashboard orang tua terpisah
- Link code system untuk menghubungkan device
- Monitoring status anak real-time
- History deteksi lengkap dengan filter
- PIN protection untuk disable monitoring (coming soon)

### 6. **Chatbot AI CBT** 💬

- Konseling mini berbasis CBT
- Penjelasan alasan deteksi
- Analisis tren perilaku pengguna
- Dukungan 24/7 dengan perspektif adaptif

### 7. **History & Analytics** 📊

- Log lengkap semua aktivitas deteksi
- Statistik mingguan dan tren
- Filter berdasarkan risiko dan aplikasi
- Grafik visualisasi data (coming soon)

### 8. **Tema Kustomisasi** 🎨

- Light Mode
- Dark Mode
- System Default

---

## 🏗️ Arsitektur Aplikasi

```
┌─────────────────────────────────────────┐
│      Flutter Frontend (Dart)            │
│                                          │
│  ┌──────────┐  ┌──────────┐            │
│  │  Child   │  │  Parent  │            │
│  │Dashboard │  │Dashboard │            │
│  └────┬─────┘  └────┬─────┘            │
│       │             │                   │
│       ▼             ▼                   │
│  ┌──────────┐  ┌──────────┐            │
│  │Monitoring│  │  History │            │
│  │  Screen  │  │ & Reports│            │
│  └──────────┘  └──────────┘            │
└─────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│    Background Services (Android)        │
│  • AutoScreenshotService                │
│  • AppDetectionService                  │
│  • OverlayService                       │
│  • ContentAnalysisService               │
└─────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│         Backend Services                │
│  • Firebase Firestore (Database)        │
│  • Firebase Auth (Authentication)       │
│  • AI Detection API (Coming)            │
│  • Cloud Functions (Notifications)      │
└─────────────────────────────────────────┘
```

---

## 💻 Tech Stack

### **Frontend**

- **Framework**: Flutter SDK 3.8.1
- **Language**: Dart
- **State Management**: GetX (Get 4.6.6)
- **UI Components**: Material Design 3, Google Fonts
- **Navigation**: GetX Navigation
- **Charts**: FL Chart 0.68.0
- **HTTP Client**: HTTP 1.2.2
- **Local Storage**: Shared Preferences 2.3.2, Flutter Secure Storage 9.2.4

### **Backend & Services**

- **Authentication**: Firebase Auth 5.3.1
- **Database**: Firebase Firestore (Firebase Core 3.6.0)
- **Notifications**: Flutter Local Notifications 17.2.2
- **Permissions**: Permission Handler 11.3.1
- **Storage**: Path Provider 2.1.4

### **Android Native**

- **MediaProjection API**: Screen capture
- **AccessibilityService**: App detection
- **WindowManager**: Overlay alerts

### **Development Tools**

- **Linting**: Flutter Lints 5.0.0
- **Date Formatting**: Intl 0.20.2
- **Dialogs**: Awesome Dialog 3.2.1
- **Toasts**: Fluttertoast 8.2.8

---

## 📁 Struktur Folder

```
paradise_app/
│
├── lib/
│   ├── main.dart                      # Entry point aplikasi
│   ├── firebase_options.dart          # Firebase configuration
│   │
│   ├── constants/                     # Konstanta & konfigurasi
│   │   └── api_constants.dart         # API URLs
│   │
│   ├── models/                        # Data models
│   │   ├── login.dart
│   │   ├── parent_settings.dart
│   │   └── statistics.dart
│   │
│   ├── controllers/                   # State management (GetX)
│   │   ├── detection_controller.dart
│   │   ├── link_controller.dart
│   │   └── settings_controller.dart
│   │
│   ├── services/                      # Business logic services
│   │   ├── monitoring/
│   │   │   ├── auto_screenshot_service.dart
│   │   │   ├── app_detection_service.dart
│   │   │   ├── screen_capture_service.dart
│   │   │   ├── overlay_service.dart
│   │   │   ├── content_analysis_service.dart
│   │   │   └── content_trigger_service.dart
│   │   ├── notifications/
│   │   │   └── notification_service.dart
│   │   └── storage/
│   │       └── secure_storage_service.dart
│   │
│   ├── views/                         # UI Layer
│   │   ├── main_navigation.dart       # Bottom nav
│   │   │
│   │   ├── screens/
│   │   │   ├── auth/                  # Login, Register
│   │   │   ├── dashboard/             # Dashboard Child & Parent
│   │   │   │   ├── dashboard_page.dart
│   │   │   │   ├── parent_dashboard_page.dart
│   │   │   │   └── child_detail_screen.dart
│   │   │   ├── monitoring/            # Monitoring screens
│   │   │   │   ├── monitoring_screen.dart
│   │   │   │   ├── monitoring_page.dart
│   │   │   │   └── detection_realtime_page.dart
│   │   │   ├── profile/               # Profile & Settings
│   │   │   │   ├── profile_page.dart
│   │   │   │   ├── parent_profile_page.dart
│   │   │   │   └── parent_settings_screen.dart
│   │   │   ├── chatbot/               # AI Chatbot
│   │   │   │   └── ai_chatbot_screen.dart
│   │   │   └── ...
│   │   │
│   │   └── widgets/                   # Reusable widgets
│   │       ├── cbt_intervention_popup.dart
│   │       ├── threat_alert_overlay.dart
│   │       └── feature_item.dart
│   │
│   └── dummy_screen_capture/          # Development dummy services
│
├── android/                           # Android native code
│   └── app/
│       └── src/main/
│           ├── kotlin/
│           │   └── com/paradise/
│           │       ├── MonitoringService.kt
│           │       ├── AccessibilityService.kt
│           │       └── ScreenCaptureService.kt
│           └── AndroidManifest.xml
│
├── assets/                            # Static assets
│   └── images/
│       └── logo_paradise.jpg
│
├── docs/                              # Documentation
│   ├── authentication_architecture.md
│   ├── BACKEND_ARCHITECTURE_ANALYSIS.md
│   ├── NSFW_MONITORING_FLOW.md
│   ├── OVERLAY_WINDOW_GUIDE.md
│   └── ...
│
├── pubspec.yaml                       # Dependencies
└── README.md                          # This file
```

---

## 🚀 Setup & Instalasi

### Prerequisites

- Flutter SDK 3.8.1 atau lebih baru
- Dart SDK
- Android Studio / VS Code dengan Flutter extension
- Android SDK (API level 21+)
- Firebase Account (untuk authentication & database)

### Langkah Instalasi

1. **Clone Repository**

   ```bash
   git clone https://github.com/yourusername/paradise_app.git
   cd paradise_app
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   - Buat project di [Firebase Console](https://console.firebase.google.com/)
   - Download `google-services.json` dan letakkan di `android/app/`
   - Copy `firebase_options.dart` ke `lib/`
   - Enable Firebase Authentication & Firestore

4. **Android Configuration**

   - Pastikan `AndroidManifest.xml` sudah memiliki permission:
     ```xml
     <uses-permission android:name="android.permission.INTERNET" />
     <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
     <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
     <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
     <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
     ```

5. **Run Application**

   ```bash
   # Check available devices
   flutter devices

   # Run on specific device
   flutter run -d <device-id>

   # Run in release mode
   flutter run --release
   ```

---

## ⚙️ Konfigurasi

### API Configuration

API base URL dikonfigurasi di `lib/constants/api_constants.dart`:

```dart
const String baseUrl = 'http://localhost:3000';
```

**Untuk production**, ubah ke URL backend:

```dart
const String baseUrl = 'https://your-production-api.com';
```

### Environment Variables (Optional)

Untuk menggunakan `.env` files:

1. Install package:

   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

2. Buat file `.env`:

   ```env
   BASE_URL=http://localhost:3000
   API_KEY=your-api-key
   ```

3. Load di `main.dart`:

   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   void main() async {
     await dotenv.load(fileName: ".env");
     runApp(MyApp());
   }
   ```

---

## 📖 Dokumentasi Lengkap

Untuk dokumentasi lengkap, silakan lihat:

- **[req.md](req.md)**: Requirements & specifications lengkap
- **[MONITORING_FEATURE_UPDATE.md](MONITORING_FEATURE_UPDATE.md)**: Update fitur monitoring terbaru
- **[IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md)**: Status implementasi fitur
- **[POPUP_TEST_GUIDE.md](POPUP_TEST_GUIDE.md)**: Panduan testing popup
- **[NSFW_MONITORING_FLOW.md](docs/NSFW_MONITORING_FLOW.md)**: Flow monitoring NSFW
- **[OVERLAY_WINDOW_GUIDE.md](docs/OVERLAY_WINDOW_GUIDE.md)**: Guide overlay window

---

## 🔑 Fitur Utama - Detail

### Monitoring dari Orang Tua (Anak Device)

**Lokasi**: Halaman Profile Anak > Section "Monitoring dari Orang Tua"

**Cara Kerja**:

1. Anak membuka halaman Profile/"Saya"
2. Toggle "Monitoring dari Orang Tua" ke **ON**
3. `AutoScreenshotService` mulai capture layar setiap 5 detik
4. Dummy detection berjalan setiap 10 detik
5. Popup CBT Intervention muncul dengan level random (Low/Medium/High)

**Note**: Monitoring berjalan di **device ANAK**, bukan device parent!

### Parental Dashboard (Parent Device)

**Lokasi**: Dashboard Orang Tua

**Fitur**:

- Lihat status monitoring anak real-time
- Generate link code untuk menghubungkan device anak
- Lihat history deteksi
- Lihat statistik aktivitas anak

**Note**: Parent **tidak perlu** menekan tombol monitoring karena monitoring berjalan di device anak.

---

## 🧪 Testing

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test test/widgets/
```

### Integration Tests

```bash
flutter test integration_test/
```

### Manual Testing

1. **Test Monitoring Feature**:

   - Buka app di device anak
   - Navigate ke Profile > "Monitoring dari Orang Tua"
   - Toggle ON
   - Tunggu popup muncul (~5-10 detik)

2. **Test Parent Dashboard**:
   - Buka app di device parent (pilih role "Orang Tua" saat login)
   - Generate link code
   - Input code di device anak
   - Lihat dashboard parent update

---

## 🤝 Kontribusi

Kontribusi sangat terbuka! Silakan fork repository ini dan ajukan pull request.

### Development Workflow

1. Fork repo
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Code Style

- Ikuti [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Gunakan `flutter format` sebelum commit
- Pastikan `flutter analyze` tidak ada warning

---

## 📝 Changelog

### Version 1.0.0 (Current)

#### Added ✨

- Dual role system (Child & Parent)
- Monitoring dari Orang Tua feature
- Auto screenshot service
- Dummy detection with CBT intervention
- Link code system untuk parent-child connection
- CBT Intervention Popup (Low/Medium/High)
- Parent dashboard dengan child monitoring
- AI Chatbot CBT
- Profile management
- Theme switcher (Light/Dark/System)

#### Features 🚀

- Background monitoring service
- Real-time detection alerts
- Screenshot gallery
- History & analytics
- Notification system

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact & Support

- **Email**: support@paradiseguardian.com
- **Documentation**: [GitHub Wiki](https://github.com/yourusername/paradise_app/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/paradise_app/issues)

---

## 🙏 Acknowledgments

- Flutter Team
- Firebase Team
- CBT Psychology Research Community
- Open Source Contributors
- Google Fonts
- Material Design Team

---

<div align="center">

**Paradise Guardian** - _Melindungi Digital Wellness dengan Teknologi AI & Psikologi_ 🛡️

Made with ❤️ by Paradise Team

</div>
