# Paradise Guardian - AI-Powered Content Monitoring App

Paradise Guardian adalah aplikasi mobile monitoring berbasis AI yang dirancang untuk mendeteksi dan mencegah paparan konten pornografi dengan pendekatan Cognitive Behavioral Therapy (CBT). Aplikasi ini membantu pengguna mengendalikan konsumsi konten digital mereka dengan intervensi psikologis otomatis dan dukungan chatbot AI.

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Arsitektur Aplikasi](#-arsitektur-aplikasi)
- [Halaman & Flow Pengguna](#-halaman--flow-pengguna)
- [Sistem Deteksi AI](#-sistem-deteksi-ai)
- [Intervensi CBT](#-intervensi-cbt)
- [Parental Control](#-parental-control)
- [Tech Stack](#-tech-stack)
- [Setup & Instalasi](#-setup--instalasi)
- [Struktur Folder](#-struktur-folder)
- [API & Backend](#-api--backend)
- [Testing](#-testing)
- [Kontribusi](#-kontribusi)

## 🌟 Fitur Utama

### 1. **AI Content Detection**

- Deteksi otomatis konten pornografi dari aplikasi target (YouTube, Twitter, Instagram, dll)
- Klasifikasi risiko: **Low**, **Medium**, **High**
- Machine Learning model untuk analisis visual real-time
- Background service monitoring berkelanjutan

### 2. **Intervensi CBT Otomatis**

Setiap deteksi memicu popup intervensi 3 komponen:

- **Trigger Identification**: Mengenali pemicu perilaku
- **Psychoeducation**: Edukasi risiko dan dampak
- **Behavioral Activation**: Saran tindakan alternatif

### 3. **Chatbot AI CBT**

- Konseling mini berbasis CBT
- Penjelasan alasan deteksi
- Analisis tren perilaku pengguna
- Dukungan 24/7 dengan perspektif adaptif

### 4. **Parental Control Mode**

- Dashboard orang tua terpisah
- Laporan deteksi komprehensif
- PIN protection untuk disable monitoring
- Notifikasi real-time untuk deteksi High Risk

### 5. **History & Analytics**

- Log lengkap semua aktivitas deteksi
- Statistik mingguan dan tren
- Filter berdasarkan risiko dan aplikasi
- Grafik visualisasi data

### 6. **Tema Kustomisasi**

- Light Mode
- Dark Mode
- System Default

---

## 🏗️ Arsitektur Aplikasi

```
┌─────────────────────────────────────────┐
│         Flutter Frontend (Dart)         │
│  ┌─────────────┐      ┌──────────────┐ │
│  │  Dashboard  │      │  Detection   │ │
│  │    Screen   │◄────►│    Screen    │ │
│  └─────────────┘      └──────────────┘ │
│         ▲                     ▲          │
│         │                     │          │
│         ▼                     ▼          │
│  ┌─────────────┐      ┌──────────────┐ │
│  │   History   │      │  Profile &   │ │
│  │   Screen    │      │   Settings   │ │
│  └─────────────┘      └──────────────┘ │
└─────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│      Background Service (Android)       │
│  • Accessibility Service                │
│  • Screen Capture Permission            │
│  • AI Detection Engine                  │
└─────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         Backend Services                │
│  • Firebase Firestore (Database)        │
│  • Firebase Auth (Authentication)       │
│  • AI Detection API (Go Backend)        │
│  • Cloud Functions (Notifications)      │
└─────────────────────────────────────────┘
```

---

## 📱 Halaman & Flow Pengguna

### **Flow Diagram Aplikasi**

```
Start App
    │
    ├─→ Permission Request (Accessibility + Screen Capture)
    │
    ├─→ Background Service Aktif
    │
    ├─→ Monitor Aplikasi Target
    │
    ├─→ AI Detection (Low/Medium/High)
    │
    ├─→ Popup Alert + CBT Intervention
    │
    ├─→ User Action (Tutup/Lanjut/Abaikan)
    │
    ├─→ Log to Firestore
    │
    └─→ Dashboard/History untuk Review
```

### 1. **Dashboard Utama** 📊

**Fungsi**: Pusat informasi dan ringkasan aktivitas monitoring

**Komponen UI**:

- **Header**: Sapaan personal "Halo, Ahmad!" + tanggal hari ini
- **Statistik Hari Ini** (Card):
  - Total Deteksi
  - Low Risk (hijau)
  - Medium Risk (kuning)
  - High Risk (merah)
- **Tren 7 Hari Terakhir**: Grafik line chart dengan indikator naik/turun
- **Aplikasi Terdeteksi**: List aplikasi + persentase risiko
- **Activity Terbaru**: Log 5 aktivitas terakhir

**Navigasi**:

- Tap Statistik → History Deteksi (filtered)
- Tap Tren Grafik → Detail tren mingguan
- Tap Aplikasi → History per aplikasi
- Tap Activity → Detail log aktivitas
- Bottom Navigation → Deteksi / History / Profile

---

### 2. **Halaman Deteksi Real-time** 🔍

**Fungsi**: Mengaktifkan/menonaktifkan monitoring otomatis

**Komponen UI**:

- **Status Indicator**:
  - `🟢 Monitoring Aktif` / `⚪ Tidak Aktif`
- **Tombol Besar**: "Mulai Deteksi" / "Hentikan Deteksi"
- **Fitur Cards**:
  - AI Detection → Icon + deskripsi
  - Smart Alert → Icon + deskripsi
- **Info Box**: Penjelasan cara kerja monitoring

**Behavior**:

- Tap "Mulai Deteksi" → Background service ON
- Jika Parental Mode ON → muncul PIN request untuk stop
- Popup alert muncul saat deteksi konten berisiko

---

### 3. **History Deteksi** 📜

**Fungsi**: Catatan lengkap semua aktivitas monitoring

**Komponen UI**:

- **Statistik Minggu Ini** (Top Card):
  - Total deteksi
  - Breakdown Low/Medium/High
- **Filter Bar**:
  - Dropdown: Semua Risiko / Low / Medium / High
  - Search: Cari berdasarkan aplikasi
- **List Riwayat**:
  - Icon aplikasi
  - Nama aplikasi
  - Badge risiko (Low/Medium/High)
  - Timestamp
  - Aksi sistem (Diblokir/Diabaikan/User Lanjut)

**Detail View** (tap salah satu item):

- Screenshot thumbnail (optional, blur untuk high risk)
- Aplikasi & risiko level
- Timestamp lengkap
- Durasi paparan
- Aksi pengguna
- CBT intervention yang diberikan

---

### 4. **Profil & Pengaturan** ⚙️

**Fungsi**: Kelola akun, preferensi, dan pengaturan sistem

**Komponen UI**:

- **Info Akun Card**:
  - Avatar
  - Nama, Email, No. HP
  - Tanggal bergabung
- **Statistik Ringkas**:
  - Total deteksi
  - Hari aktif
- **Menu Pengaturan**:
  - **Notifikasi** (Toggle):
    - Alert saat konten berisiko
    - High Risk Only mode
  - **Aplikasi**:
    - Pengaturan Umum
    - Keamanan & Privasi
    - Bantuan & Dukungan
  - **Akun**:
    - Edit Informasi Akun
    - Keluar

**Navigasi**:

- Bottom navigation untuk pindah halaman
- Back button untuk kembali

---

## 🤖 Sistem Deteksi AI

### **Kriteria Level Risiko**

| Level         | Kriteria                           | Contoh Konten                                                |
| ------------- | ---------------------------------- | ------------------------------------------------------------ |
| **🟢 LOW**    | Paparan ringan, borderline         | Thumbnail suggestive, pakaian minim (tidak eksplisit)        |
| **🟡 MEDIUM** | Semi-pornografi, suggestive tinggi | Pose sensual, pakaian sangat terbuka, konten erotis          |
| **🔴 HIGH**   | Pornografi eksplisit               | Nudity, aktivitas seksual, konten pornografi terang-terangan |

### **Proses Deteksi**

1. **Background Service** memantau aplikasi target (YouTube, Twitter, Instagram, TikTok, dll)
2. **Screen Capture** mengambil screenshot saat aplikasi aktif
3. **AI Model** menganalisis gambar dengan CNN/Vision Transformer
4. **Klasifikasi** risiko berdasarkan confidence score
5. **Trigger Popup** sesuai level risiko
6. **Log ke Firestore** untuk history

---

## 🧠 Intervensi CBT

### **Struktur Popup Intervensi**

Setiap popup memuat 3 komponen CBT:

#### **🟢 LOW RISK - Popup Intervensi**

```
╔═══════════════════════════════════════╗
║  ⚠️  KONTEN SENSITIF TERDETEKSI      ║
╠═══════════════════════════════════════╣
║ 🧩 Trigger Identification             ║
║ "Sepertinya kamu melihat konten yang  ║
║ agak sensitif. Kadang thumbnail atau  ║
║ gambar tertentu bisa memicu rasa      ║
║ penasaran tanpa disadari."            ║
║                                       ║
║ 📘 Psychoeducation                    ║
║ "Konten seperti ini bisa mengganggu   ║
║ fokus dan membentuk kebiasaan         ║
║ scrolling impulsif. Menyadarinya      ║
║ sejak awal membantu kamu tetap        ║
║ terkontrol."                          ║
║                                       ║
║ ⚡ Behavioral Activation              ║
║ "Coba lanjutkan ke aktivitas lain     ║
║ yang kamu rencanakan. Kamu bisa       ║
║ alihkan ke aplikasi belajar atau      ║
║ musik santai."                        ║
║                                       ║
║         [Tutup]                       ║
╚═══════════════════════════════════════╝
```

#### **🟡 MEDIUM RISK - Popup Intervensi**

```
╔═══════════════════════════════════════╗
║  ⚠️  KONTEN BERISIKO TERDETEKSI      ║
╠═══════════════════════════════════════╣
║ 🧩 Trigger Identification             ║
║ "Kamu sedang terpapar konten yang     ║
║ memicu dorongan visual. Situasi ini   ║
║ sering muncul tanpa disengaja dari    ║
║ rekomendasi aplikasi."                ║
║                                       ║
║ 📘 Psychoeducation                    ║
║ "Konten semi-pornografi dapat         ║
║ memperkuat kebiasaan menonton         ║
║ berulang dan memengaruhi kontrol      ║
║ diri, apalagi jika kamu sedang stres  ║
║ atau bosan."                          ║
║                                       ║
║ ⚡ Behavioral Activation              ║
║ "Ambil jeda sebentar. Kamu bisa:      ║
║ • Tutup aplikasi ini                  ║
║ • Buka sesuatu yang lebih aman        ║
║ • Tarik napas dalam 30 detik"         ║
║                                       ║
║      [Tutup Aplikasi]                 ║
╚═══════════════════════════════════════╝
```

#### **🔴 HIGH RISK - Popup Intervensi**

```
╔═══════════════════════════════════════╗
║  🚨  KONTEN PORNOGRAFI TERDETEKSI    ║
╠═══════════════════════════════════════╣
║ 🧩 Trigger Identification             ║
║ "Sistem mendeteksi konten pornografi  ║
║ eksplisit. Situasi seperti ini sering ║
║ memicu dorongan kuat dan pola         ║
║ konsumsi impulsif."                   ║
║                                       ║
║ 📘 Psychoeducation                    ║
║ "Paparan pornografi berulang dapat    ║
║ memengaruhi regulasi emosi, mengubah  ║
║ pola pikir tentang relasi, dan        ║
║ memicu kebiasaan adiktif. Mengambil   ║
║ langkah cepat di momen ini sangat     ║
║ penting."                             ║
║                                       ║
║ ⚡ Behavioral Activation              ║
║ "Konten ini diblokir untuk melindungi ║
║ kamu. Kamu bisa mengalihkan aktivitas,║
║ lakukan deep breathing 30 detik, atau ║
║ gunakan bantuan CBT chatbot."         ║
║                                       ║
║         [Tutup]                       ║
╚═══════════════════════════════════════╝

Sistem otomatis:
✓ Memblokir konten
✓ Menyimpan log risiko
✓ Mengirim notifikasi ke parental (jika ON)
```

---

## 👨‍👩‍👧 Parental Control

### **Flow Parental Mode**

```
Parent Mode OFF
    │
    ├─→ Anak bisa ON/OFF monitoring bebas
    │
    └─→ Tidak ada PIN protection

Parent Mode ON
    │
    ├─→ Monitoring LOCKED
    │
    ├─→ Anak tidak bisa matikan tanpa PIN
    │
    ├─→ Tap "Hentikan Deteksi" → PIN Request
    │
    ├─→ PIN Benar → Monitoring OFF
    │
    └─→ PIN Salah → Ditolak
```

### **1. Parent Dashboard** 👨‍👩‍👧‍👦

**Komponen UI**:

- **Sapaan**: "Halo, Ayah/Bunda dari Ahmad 👋"
- **Ringkasan Deteksi Hari Ini**:
  - Total deteksi (Low/Medium/High)
  - Deteksi terakhir (jam & aplikasi)
- **Tren 7 Hari**: Grafik sederhana jumlah deteksi
- **Aplikasi Paling Sering**:
  - YouTube – 43%
  - Twitter – 31%
- **Status Monitoring**:
  - `🔒 ON (locked by parent)` / `⚪ OFF`
- **Tombol**:
  - History Deteksi
  - Pengaturan Monitoring

---

### **2. Parent History Deteksi** 📋

**Komponen UI**:

- **Statistik Minggu Ini**: Total deteksi + breakdown risiko
- **Filter**: Risiko, Aplikasi, Tanggal
- **Riwayat Deteksi** (metadata saja):
  - Aplikasi
  - Risiko level
  - Aksi anak (ditutup/diabaikan/lanjut)
  - Timestamp

**Detail View**:

- Aplikasi
- Risiko
- Jam
- Aksi anak

---

### **3. Pengaturan PIN** 🔐

**Komponen UI**:

- **Toggle**: Aktifkan Parental Mode
- **Input PIN**: 4-6 digit
- **Konfirmasi PIN**
- **Info**: Penjelasan fungsi PIN

**Behavior**:

- PIN disimpan terenkripsi di Firestore
- Validasi PIN setiap kali anak mau disable monitoring

---

## 💬 Chatbot AI CBT

### **Fitur Chatbot**

1. **Perspektif Dual**:

   - Mode Pengguna: Fokus pada self-reflection & coping strategies
   - Mode Parental: Fokus pada insight & guidance untuk orang tua

2. **Capabilities**:

   - Menjelaskan alasan deteksi
   - Edukasi risiko konten pornografi
   - Mini-counseling berbasis CBT
   - Analisis tren perilaku
   - Saran aktivitas alternatif
   - Dukungan emosional

3. **Contoh Interaksi**:

```
User: "Kenapa YouTube sering terdeteksi?"

Bot: "Dari data kamu, YouTube terdeteksi 12x minggu ini,
mayoritas Medium Risk. Ini biasanya dari thumbnail video
suggestive di recommendation feed.

Beberapa trigger yang bisa kamu waspadai:
• Scroll feed tanpa tujuan spesifik
• Waktu bosan (sore & malam)
• Setelah stres dari aktivitas lain

Coba strategi ini:
✓ Set tujuan spesifik sebelum buka YouTube
✓ Gunakan Search langsung, hindari feed
✓ Aktifkan Restricted Mode di settings

Mau saya bantu set reminder untuk habit baru?"
```

---

## 🛠️ Tech Stack

### **Frontend (Flutter)**

- **Framework**: Flutter SDK 3.x
- **State Management**: Provider / Riverpod
- **UI Components**: Material Design 3
- **Navigation**: GoRouter
- **Charts**: FL Chart
- **HTTP Client**: Dio
- **Local Storage**: Shared Preferences / Hive

### **Backend**

- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Cloud Functions**: Firebase Functions (Node.js/TypeScript)
- **AI Detection API**: Go (Gin framework) - `paradise_be`
- **Real-time Updates**: Firestore Streams

### **AI/ML**

- **Model**: CNN / Vision Transformer
- **Framework**: TensorFlow / PyTorch
- **Deployment**: TensorFlow Lite (on-device) + Cloud API

### **Android Native**

- **Background Service**: Foreground Service
- **Accessibility Service**: AccessibilityService API
- **Screen Capture**: MediaProjection API

---

## 🚀 Setup & Instalasi

### **Prerequisites**

- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Firebase CLI
- Git

### **Instalasi**

1. **Clone Repository**

```bash
cd C:\Users\Lenovo\Documents\Paradise
git clone <repository-url> fe_zikri
cd fe_zikri
```

2. **Install Dependencies**

```bash
flutter pub get
```

3. **Setup Firebase**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

4. **Setup Android**

- Buka `android/` di Android Studio
- Sync Gradle
- Tambahkan permission di `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />
```

5. **Run App**

```bash
flutter run
```

### **Environment Variables**

Buat file `.env` di root:

```env
API_BASE_URL=https://your-backend.com/api
FIREBASE_PROJECT_ID=your-project-id
AI_DETECTION_API_KEY=your-api-key
```

---

## 📂 Struktur Folder

```
fe_zikri/
├── lib/
│   ├── main.dart                  # Entry point
│   ├── app.dart                   # App wrapper (theme, routes)
│   │
│   ├── core/
│   │   ├── constants/             # Colors, strings, app constants
│   │   ├── routes/                # Route definitions (GoRouter)
│   │   ├── theme/                 # Light/Dark theme
│   │   └── utils/                 # Helper functions
│   │
│   ├── data/
│   │   ├── models/                # Data models (User, Detection, etc)
│   │   ├── repositories/          # Data layer (Firestore, API calls)
│   │   └── services/              # Background service, AI detection
│   │
│   ├── domain/
│   │   ├── entities/              # Business entities
│   │   └── usecases/              # Business logic
│   │
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── dashboard/         # Dashboard screen
│   │   │   ├── detection/         # Detection screen
│   │   │   ├── history/           # History screen
│   │   │   ├── profile/           # Profile & settings
│   │   │   ├── parental/          # Parental control screens
│   │   │   └── auth/              # Login, register
│   │   │
│   │   ├── widgets/               # Reusable widgets
│   │   │   ├── cards/
│   │   │   ├── buttons/
│   │   │   ├── charts/
│   │   │   └── dialogs/
│   │   │
│   │   └── providers/             # State management (Provider/Riverpod)
│   │
│   └── l10n/                      # Localization (ID/EN)
│
├── android/
│   ├── app/
│   │   └── src/
│   │       └── main/
│   │           ├── kotlin/
│   │           │   └── com/paradise/
│   │           │       ├── MonitoringService.kt
│   │           │       ├── AccessibilityService.kt
│   │           │       └── ScreenCaptureService.kt
│   │           └── AndroidManifest.xml
│   └── build.gradle
│
├── assets/
│   ├── images/                    # Icons, illustrations
│   ├── fonts/                     # Custom fonts
│   └── animations/                # Lottie animations
│
├── test/                          # Unit & widget tests
├── integration_test/              # Integration tests
├── pubspec.yaml
└── README.md
```

---

## 🔗 API & Backend

### **Endpoints**

#### **Authentication**

```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
GET  /api/auth/me
```

#### **Detection**

```
POST /api/detection/analyze       # Kirim screenshot untuk analisis AI
GET  /api/detection/history       # Ambil history deteksi
GET  /api/detection/stats         # Ambil statistik deteksi
```

#### **Parental**

```
POST /api/parental/enable         # Aktifkan parental mode
POST /api/parental/verify-pin     # Verifikasi PIN
GET  /api/parental/dashboard      # Dashboard orang tua
```

#### **Chatbot**

```
POST /api/chatbot/message         # Kirim pesan ke chatbot
GET  /api/chatbot/history         # History chat
```

### **Firestore Collections**

```
users/
  ├── {userId}/
  │   ├── profile: { name, email, phone, joinedAt }
  │   ├── settings: { notifications, highRiskOnly, theme }
  │   └── parentalMode: { enabled, pin, parentEmail }

detections/
  ├── {detectionId}/
  │   ├── userId: string
  │   ├── appName: string
  │   ├── riskLevel: "low" | "medium" | "high"
  │   ├── timestamp: Timestamp
  │   ├── action: "blocked" | "ignored" | "continued"
  │   └── screenshotUrl: string (optional)

chatHistory/
  ├── {userId}/
  │   └── messages: [
  │       { role: "user" | "bot", message: string, timestamp }
  │     ]
```

---

## 🧪 Testing

### **Unit Tests**

```bash
flutter test
```

### **Widget Tests**

```bash
flutter test test/widgets/
```

### **Integration Tests**

```bash
flutter test integration_test/
```

### **Coverage**

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 🎨 UI Design Guidelines

### **Color Palette**

#### **Light Mode**

- Primary: `#2563EB` (Blue)
- Secondary: `#10B981` (Green)
- Danger: `#EF4444` (Red)
- Warning: `#F59E0B` (Amber)
- Background: `#FFFFFF`
- Surface: `#F3F4F6`
- Text Primary: `#111827`
- Text Secondary: `#6B7280`

#### **Dark Mode**

- Primary: `#3B82F6`
- Secondary: `#34D399`
- Danger: `#F87171`
- Warning: `#FBBF24`
- Background: `#111827`
- Surface: `#1F2937`
- Text Primary: `#F9FAFB`
- Text Secondary: `#9CA3AF`

### **Typography**

- **Heading 1**: 32sp, Bold
- **Heading 2**: 24sp, SemiBold
- **Body**: 16sp, Regular
- **Caption**: 14sp, Regular
- **Button**: 16sp, Medium

### **Spacing**

- XS: 4dp
- S: 8dp
- M: 16dp
- L: 24dp
- XL: 32dp

---

## 🤝 Kontribusi

Kontribusi sangat terbuka! Silakan fork repository ini dan ajukan pull request.

### **Development Workflow**

1. Fork repo
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 📞 Contact & Support

- **Email**: support@paradiseguardian.com
- **Website**: https://paradiseguardian.com
- **Discord**: https://discord.gg/paradise

---

## 🙏 Acknowledgments

- Flutter Team
- Firebase Team
- CBT Psychology Research Community
- Open Source Contributors

---

**Paradise Guardian** - _Melindungi Digital Wellness dengan Teknologi AI & Psikologi_ 🛡️
