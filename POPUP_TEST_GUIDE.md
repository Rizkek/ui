# 🧪 Panduan Testing Popup Blok Konten

## Ringkasan Fitur

Fitur ini memungkinkan Anda untuk **testing popup blok konten dengan berbagai tingkat risiko** pada dashboard anak tanpa perlu benar-benar mengakses konten pornografi. Ini adalah **hidden feature** yang dapat diaktifkan dengan mudah.

---

## 🎯 Cara Menggunakan

### 1. **Membuka Child Detail Screen**

- Navigasi ke dashboard anak dengan membuka salah satu akun anak dari parent profile
- Atau jika sudah di dashboard, klik pada kartu anak untuk membuka detail screen

### 2. **Mengaktifkan Test Popup Menu**

Ada **2 cara** untuk mengaktifkan menu testing:

#### **Cara 1: Double Tap pada Title (Recommended)**

```
1. Lihat AppBar dengan judul "Detail [Nama Anak]"
2. Double-tap (tap 2x dengan cepat) pada judul tersebut
3. Dialog pemilihan level risiko akan muncul
```

#### **Cara 2: Triple Tap pada Logo (Alternative)**

```
1. Lihat AppBar dengan logo di sebelah kiri
2. Triple-tap (tap 3x dengan cepat) pada logo
3. Menu testing akan muncul
```

---

## 📊 Pilihan Level Risiko

Setelah mengaktifkan menu testing, Anda akan melihat 3 opsi:

### **1. LOW RISK (Risiko Rendah) 🟡**

```
Aplikasi: Chrome Browser
Deskripsi: Konten dengan sedikit elemen yang tidak sesuai umur
Trigger: Partial Nudity
Aksi: Peringatan diberikan kepada anak
Warna: Kuning
```

**Pesan Edukasi:**

- Konten ini mengandung elemen yang mungkin tidak sesuai untuk usia Anda
- Orang tua Anda telah diberitahu tentang akses ini
- Silakan berkomunikasi dengan orang tua jika ada pertanyaan

---

### **2. MEDIUM RISK (Risiko Sedang) 🟠**

```
Aplikasi: Instagram
Deskripsi: Konten dengan elemen-elemen yang suggestive/tidak sesuai umur
Trigger: Adult Content, Suggestive Imagery
Aksi: Peringatan + Notifikasi ke orang tua
Warna: Orange
```

**Pesan Edukasi:**

- Konten yang Anda coba akses memiliki rating untuk dewasa
- Pihak pengawas telah menerima notifikasi
- Kami mendorong untuk berbicara dengan orang tua tentang kekhawatiran

---

### **3. HIGH RISK (Risiko Tinggi) 🔴**

```
Aplikasi: Situs Pornografi (Blocked)
Deskripsi: Konten pornografi atau sangat tidak sesuai umur
Trigger: Explicit Content, NSFW, Sexual Material
Aksi: Konten diblokir otomatis + Notifikasi urgent
Warna: Merah
Status: Konten DIBLOKIR
```

**Pesan Edukasi:**

- Konten ini telah diidentifikasi sebagai tidak aman dan telah diblokir
- Akses ke konten eksplisit diblokir demi melindungi kesehatan dan keselamatan Anda
- Jika penyaringan terlalu ketat, silakan diskusikan dengan orang tua

---

## 🎨 UI/UX Penampilan Popup

### Struktur Popup Block:

```
┌─────────────────────────────────┐
│  [Icon] Konten Terdeteksi!       │ ← Header dengan gradient warna
│          Risiko [Level]          │
├─────────────────────────────────┤
│  📱 Aplikasi: [App Name]         │
│  ⚠️ Level Risiko: [Level]        │
│  📍 Deteksi: [Content Type]      │
│                                  │
│  🔍 Trigger Terdeteksi:          │
│     • [Trigger 1]                │
│     • [Trigger 2]                │
│     • [Trigger 3]                │
│                                  │
│  [Informasi] [Coba Lagi] [Keluar]│ ← Action buttons
└─────────────────────────────────┘
```

---

## 🛠️ File-File yang Terlibat

### 1. **test_popup_helper.dart** (New)

```
lib/services/test_popup_helper.dart
```

Berisi helper functions untuk:

- `showRiskLevelSelector()` - Menampilkan dialog pemilihan level
- `_showTestBlockPopup()` - Menampilkan popup dengan data dummy
- `_showPsychoeducationInfo()` - Menampilkan info edukasi

### 2. **child_detail_screen.dart** (Modified)

```
lib/views/screens/dashboard/child_detail_screen.dart
```

Perubahan:

- Import TestPopupHelper
- Tambah variabel `_titleTapCount` dan `_lastTitleTapTime`
- Tambah method `_handleTitleTap()`
- Wrap title dengan `GestureDetector`

### 3. **content_block_popup.dart** (Existing)

```
lib/views/widgets/content_block_popup.dart
```

Widget yang menampilkan popup block (sudah ada sebelumnya)

### 4. **risk_detection.dart** (Existing)

```
lib/models/risk_detection.dart
```

Model data untuk deteksi risiko

---

## 📋 Data Dummy Berdasarkan Level

### **LOW RISK**

| Field      | Nilai                                               |
| ---------- | --------------------------------------------------- |
| App Name   | Chrome Browser                                      |
| Package    | com.android.chrome                                  |
| Content    | Konten dengan sedikit elemen yang tidak sesuai umur |
| Triggers   | `['Partial Nudity']`                                |
| Is Blocked | false                                               |

### **MEDIUM RISK**

| Field      | Nilai                                                         |
| ---------- | ------------------------------------------------------------- |
| App Name   | Instagram                                                     |
| Package    | com.instagram.android                                         |
| Content    | Konten dengan elemen-elemen yang suggestive/tidak sesuai umur |
| Triggers   | `['Adult Content', 'Suggestive Imagery']`                     |
| Is Blocked | false                                                         |

### **HIGH RISK**

| Field      | Nilai                                             |
| ---------- | ------------------------------------------------- |
| App Name   | Situs Pornografi (Blocked)                        |
| Package    | com.blocked.content                               |
| Content    | Konten pornografi atau sangat tidak sesuai umur   |
| Triggers   | `['Explicit Content', 'NSFW', 'Sexual Material']` |
| Is Blocked | true                                              |

---

## 🔍 Testing Scenarios

### Scenario 1: Test Deteksi Low Risk

```
1. Buka Child Detail Screen
2. Double-tap judul
3. Klik tombol "Low Risk"
4. Verifikasi:
   - ✓ Popup muncul dengan warna kuning
   - ✓ Icon info_outline ditampilkan
   - ✓ Aplikasi: Chrome Browser
   - ✓ Trigger: Partial Nudity
   - ✓ Button "Informasi" berfungsi
```

### Scenario 2: Test Deteksi Medium Risk

```
1. Buka Child Detail Screen
2. Double-tap judul
3. Klik tombol "Medium Risk"
4. Verifikasi:
   - ✓ Popup muncul dengan warna orange
   - ✓ Icon warning_amber_rounded ditampilkan
   - ✓ Aplikasi: Instagram
   - ✓ Triggers: Adult Content, Suggestive Imagery
```

### Scenario 3: Test Deteksi High Risk + Block

```
1. Buka Child Detail Screen
2. Double-tap judul
3. Klik tombol "High Risk"
4. Verifikasi:
   - ✓ Popup muncul dengan warna merah
   - ✓ Icon dangerous_outlined ditampilkan
   - ✓ Aplikasi: Situs Pornografi (Blocked)
   - ✓ Status: Konten DIBLOKIR ditampilkan
   - ✓ Triggers: Explicit Content, NSFW, Sexual Material
```

### Scenario 4: Test Psychoeducation Info

```
1. Lakukan salah satu testing di atas
2. Klik tombol "Informasi"
3. Verifikasi:
   - ✓ Dialog dengan info edukasi muncul
   - ✓ Judul sesuai dengan level
   - ✓ Konten edukasi sesuai dengan level
   - ✓ Button "Tutup" berfungsi
```

---

## 📝 Catatan Penting

### Keamanan

- ✅ Fitur ini **HANYA untuk testing/demo**
- ✅ Tidak ada konten asli yang ditampilkan
- ✅ Data yang ditampilkan sepenuhnya **dummy/simulasi**
- ✅ Cocok untuk demo ke stakeholder/parent

### Perawatan

- ✅ Tap detection hanya berlaku di Child Detail Screen
- ✅ Timer reset otomatis setelah 500ms
- ✅ Tidak ada persistent state yang disimpan
- ✅ Popup dapat ditutup dengan tombol atau back button

### Keterbatasan

- ❌ Popup ini hanya untuk testing UI/UX
- ❌ Tidak meng-update database/Firestore
- ❌ Tidak mengirim notifikasi ke parent sebenarnya
- ❌ Tidak merekam riwayat deteksi

---

## 🔧 Cara Menambah Level Baru (Optional)

Jika Anda ingin menambah level baru atau memodifikasi existing:

### Edit `test_popup_helper.dart`:

```dart
// Tambah case baru di method-method berikut:

// 1. _getAppName()
case RiskLevel.custom:
  return 'Your App Name';

// 2. _getPackageName()
case RiskLevel.custom:
  return 'com.your.package';

// 3. _getContentDescription()
case RiskLevel.custom:
  return 'Your content description';

// 4. _getTriggers()
case RiskLevel.custom:
  return ['Trigger 1', 'Trigger 2'];

// 5. _getPsychoeducationTitle()
case RiskLevel.custom:
  return 'Your Title';

// 6. _getPsychoeducationContent()
case RiskLevel.custom:
  return 'Your education content';
```

---

## ❓ FAQ

**Q: Bagaimana cara menghapus fitur ini?**
A: Hapus import `test_popup_helper.dart` dan hilangkan `_handleTitleTap()` method dari `child_detail_screen.dart`

**Q: Bisakah diakses dari mana saja?**
A: Hanya dari Child Detail Screen saat melakukan double-tap pada title

**Q: Apakah ini benar-benar trigger popup yang sebenarnya?**
A: Ya! Ini menggunakan `ContentBlockPopup.show()` yang sama dengan deteksi asli, hanya dengan data dummy

**Q: Bagaimana cara test dengan data real?**
A: Gunakan simulasi monitoring di layar monitoring screen yang sudah ada

---

## 🚀 Pengembangan Lebih Lanjut

Fitur yang bisa ditambahkan:

- [ ] Customizable dummy app names via dialog
- [ ] Customizable trigger text
- [ ] Save favorite test scenarios
- [ ] Export test results to PDF
- [ ] Integration dengan analytics

---

**Last Updated:** January 5, 2026
**Status:** ✅ Ready for Testing
