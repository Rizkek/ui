# 🚨 Implementasi Full-Screen NSFW Notification

## 📋 Overview

Sistem ini menampilkan **full-screen notification** secara otomatis ketika API `/api/detectnsfw` mengembalikan `nsfw_level` dengan nilai **1, 2, atau 3**. Notifikasi menggunakan desain immersive (tanpa status bar/navigation bar) dengan tampilan berbeda untuk tiap level risiko.

---

## 🎯 Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Auto Screenshot Service                   │
│                  (setiap 5 detik)                            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │ 1. Capture Screenshot │
              │ 2. Detect App Name    │
              └──────────┬───────────┘
                         │
                         ▼
              ┌──────────────────────────────────┐
              │  POST /api/detectnsfw            │
              │  - Headers: Bearer JWT           │
              │  - Body: image (file)            │
              │  - Body: application (text)      │
              └──────────┬───────────────────────┘
                         │
                         ▼
              ┌──────────────────────────────────┐
              │  Response from API:              │
              │  {                               │
              │    "nsfw_level": 0-3,            │
              │    "status": "success"           │
              │  }                               │
              └──────────┬───────────────────────┘
                         │
                         ▼
              ┌──────────────────────────────────┐
              │  Parse nsfw_level                │
              └──────────┬───────────────────────┘
                         │
                ┌────────┴────────┐
                │                 │
        level = 0          level > 0 (1, 2, atau 3)
                │                 │
                ▼                 ▼
         ✅ No Action    🚨 Trigger latestNsfwDetection.value
                                  │
                                  ▼
                      ┌───────────────────────────┐
                      │  MonitoringScreen Listener │
                      │  (ever() dari GetX)        │
                      └───────────┬───────────────┘
                                  │
                                  ▼
                      ┌───────────────────────────┐
                      │  Navigator.push()         │
                      │  → NsfwAlertScreen        │
                      │    (Full-screen immersive)│
                      └───────────────────────────┘
```

---

## 📊 NSFW Level Specification

| Level | Nama   | Warna  | Icon                    | Aksi User                        |
|-------|--------|--------|-------------------------|----------------------------------|
| **0** | SAFE   | Green  | ✅ check_circle         | Tidak ada notifikasi             |
| **1** | LOW    | Amber  | ℹ️ info                 | Abaikan atau Tutup App           |
| **2** | MEDIUM | Orange | ⚠️ warning_amber        | Tutup Aplikasi (recommended)     |
| **3** | HIGH   | Red    | 🛡️ shield              | Tutup Aplikasi (strongly urge)   |

---

## 🔧 File-file yang Dibuat/Dimodifikasi

### 1️⃣ **nsfw_alert_screen.dart** (NEW)
**Path:** `lib/dummy_screen_capture/widgets/nsfw_alert_screen.dart`

**Fungsi:** Widget full-screen untuk menampilkan peringatan NSFW

**Fitur:**
- ✅ Immersive mode (tanpa status bar & navigation bar)
- ✅ Animasi pulse pada ikon
- ✅ Gradient background dengan warna sesuai level
- ✅ Badge level (LOW/MEDIUM/HIGH)
- ✅ Pesan khusus per level
- ✅ Button "Abaikan" hanya untuk level 1 (LOW)
- ✅ Button "Tutup Aplikasi" untuk semua level
- ✅ Close button (X) di pojok kanan atas hanya untuk level 1

**Key Code:**
```dart
class NsfwAlertScreen extends StatefulWidget {
  final int nsfwLevel;      // 0-3
  final String appName;     // Nama app yang terdeteksi
  
  // Menampilkan alert dengan animasi fade
  // SystemUiMode.immersiveSticky untuk full-screen
}
```

---

### 2️⃣ **auto_screenshot_service.dart** (MODIFIED)
**Path:** `lib/dummy_screen_capture/services/auto_screenshot_service.dart`

**Perubahan:**

#### Import baru:
```dart
import 'dart:convert';  // Untuk json.decode()
import '../widgets/nsfw_alert_screen.dart';
```

#### Observable baru:
```dart
final Rx<NsfwDetection?> latestNsfwDetection = Rx<NsfwDetection?>(null);
```
Digunakan untuk trigger notifikasi ke UI

#### Modifikasi `_sendToDetectNsfwApi()`:
- Return type berubah dari `Future<bool>` → `Future<int?>`
- Parse response JSON untuk ambil `nsfw_level`
- Return `int` (0-3) jika sukses, `null` jika gagal

**Key Code:**
```dart
// Parse response
final Map<String, dynamic> responseData = json.decode(response.body);
final int nsfwLevel = responseData['nsfw_level'] ?? 0;
return nsfwLevel;
```

#### Modifikasi `_captureAndSave()`:
- Simpan `nsfw_level` ke screenshots list
- Trigger notifikasi jika level > 0

**Key Code:**
```dart
if (nsfwLevel > 0) {
  latestNsfwDetection.value = NsfwDetection(
    level: nsfwLevel,
    appName: appName,
    timestamp: DateTime.now(),
  );
  print('🚨 NSFW detected! Triggering alert...');
}
```

#### Model baru:
```dart
class NsfwDetection {
  final int level;
  final String appName;
  final DateTime timestamp;
}
```

---

### 3️⃣ **monitoring_screen.dart** (MODIFIED)
**Path:** `lib/dummy_screen_capture/screens/monitoring_screen.dart`

**Perubahan:**

#### Import baru:
```dart
import '../widgets/nsfw_alert_screen.dart';
```

#### Listener baru di `initState()`:
```dart
void _setupNsfwListener() {
  // GetX ever() listener
  ever(_screenshotService.latestNsfwDetection, (detection) {
    if (detection != null && detection.level > 0) {
      _showNsfwAlert(detection);
      
      // Reset after showing
      Future.delayed(const Duration(milliseconds: 500), () {
        _screenshotService.latestNsfwDetection.value = null;
      });
    }
  });
}
```

#### Method untuk show alert:
```dart
void _showNsfwAlert(NsfwDetection detection) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: true,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) =>
          NsfwAlertScreen(
            nsfwLevel: detection.level,
            appName: detection.appName,
          ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}
```

---

## 🎬 User Experience Flow

### **Scenario 1: Level 0 (SAFE)**
```
User membuka app Instagram
  ↓
Screenshot diambil setiap 5 detik
  ↓
API response: { "nsfw_level": 0, "status": "success" }
  ↓
✅ Tidak ada notifikasi
  ↓
User tetap bisa pakai app normal
```

### **Scenario 2: Level 1 (LOW)**
```
User membuka app dengan konten berisiko rendah
  ↓
Screenshot diambil
  ↓
API response: { "nsfw_level": 1, "status": "success" }
  ↓
🚨 Full-screen alert muncul (Amber color)
  ┌─────────────────────────────┐
  │  ℹ️  LEVEL 1: LOW            │
  │                             │
  │  Peringatan Konten Rendah   │
  │                             │
  │  Terdeteksi konten yang...  │
  │                             │
  │  [Abaikan]  [Tutup App]     │
  └─────────────────────────────┘
  ↓
User bisa pilih:
  - Abaikan (tutup notifikasi, lanjut pakai app)
  - Tutup App (close app yang terdeteksi)
```

### **Scenario 3: Level 2 (MEDIUM)**
```
User membuka app dengan konten tidak pantas
  ↓
API response: { "nsfw_level": 2, "status": "success" }
  ↓
🚨 Full-screen alert muncul (Orange color)
  ┌─────────────────────────────┐
  │  ⚠️  LEVEL 2: MEDIUM         │
  │                             │
  │  Peringatan Konten Sedang   │
  │                             │
  │  Terdeteksi konten tidak... │
  │                             │
  │    [🚪 Tutup Aplikasi]      │
  └─────────────────────────────┘
  ↓
User HANYA bisa:
  - Tutup App (tidak ada tombol Abaikan)
```

### **Scenario 4: Level 3 (HIGH)**
```
User membuka app dengan konten sangat tidak pantas
  ↓
API response: { "nsfw_level": 3, "status": "success" }
  ↓
🚨 Full-screen alert muncul (Red color)
  ┌─────────────────────────────┐
  │  🛡️  LEVEL 3: HIGH           │
  │                             │
  │  Peringatan Konten Tinggi   │
  │                             │
  │  Terdeteksi konten sangat...│
  │                             │
  │    [🚪 Tutup Aplikasi]      │
  └─────────────────────────────┘
  ↓
User HARUS tutup app (tidak bisa back button)
```

---

## 🧪 Testing Guide

### **1. Test API Response**
Pastikan backend (`detectnsfw.go`) sudah return format yang benar:

```json
{
  "nsfw_level": 0,  // atau 1, 2, 3
  "status": "success"
}
```

### **2. Test Auto Screenshot Service**
1. Jalankan app di Android device
2. Buka tab "Monitoring" di bottom navigation
3. Klik "Start Monitoring"
4. Buka app lain (misalnya Chrome, Instagram, dll)
5. Tunggu 5 detik
6. Check console log:
   ```
   📸 Starting first actual capture...
   📱 Current app: Chrome
   📤 Sending to API: http://192.168.1.36:3000/api/detectnsfw
   ✅ API call successful: 200
   📊 Parsed NSFW Level: 1
   🚨 NSFW detected! Triggering alert...
   ```

### **3. Test Full-Screen Alert**
Simulasi berbagai level dengan memodifikasi response backend sementara:

**Level 1 (LOW):**
```go
// detectnsfw.go - temporary test
c.JSON(http.StatusOK, gin.H{
    "nsfw_level": 1,
    "status":     "success",
})
```

**Level 2 (MEDIUM):**
```go
c.JSON(http.StatusOK, gin.H{
    "nsfw_level": 2,
    "status":     "success",
})
```

**Level 3 (HIGH):**
```go
c.JSON(http.StatusOK, gin.H{
    "nsfw_level": 3,
    "status":     "success",
})
```

### **4. Test User Interaction**
- ✅ Level 1: Tombol "Abaikan" harus tutup alert
- ✅ Level 1: Tombol "Tutup App" harus tutup alert (TODO: implement actual app closing)
- ✅ Level 2/3: Hanya ada tombol "Tutup Aplikasi"
- ✅ Level 1: Close button (X) di pojok kanan atas berfungsi
- ✅ Level 2/3: Tidak ada close button
- ✅ Level 2/3: Back button tidak berfungsi (WillPopScope)

---

## 🎨 Design Specifications

### **Color Palette**
```dart
Level 0 (SAFE):    #10B981  (Emerald Green)
Level 1 (LOW):     #F59E0B  (Amber)
Level 2 (MEDIUM):  #EA580C  (Orange)
Level 3 (HIGH):    #DC2626  (Red)
```

### **Typography**
- Font: Google Fonts Inter
- Title: 28px, Bold (w800)
- Message: 16px, Regular
- Badge: 14px, Extra Bold (w800), Letter spacing 1.5

### **Animations**
- Pulse animation: 1.5s, repeat reverse
- Scale: 1.0 → 1.1
- Fade transition when opening alert

### **Layout**
- Background: Black with opacity 0.95
- Gradient: Radial from center (accent color 0.2 opacity → black 0.9)
- Icon size: 60px in 120x120 circle
- Padding: 32px horizontal
- Border radius: 16px for cards, 30px for badges

---

## 🚀 Future Improvements

### **1. Implementasi Close App**
Saat ini tombol "Tutup Aplikasi" hanya menutup alert. Perlu implementasi native code untuk:
- Force close app yang terdeteksi (requires root/accessibility service)
- Atau minimal buka recent apps screen

### **2. History Log**
Simpan semua deteksi NSFW dengan timestamp:
```dart
List<NsfwDetection> detectionHistory = [];
```

### **3. Vibration Feedback**
Tambahkan vibration saat alert muncul:
```dart
import 'package:vibration/vibration.dart';

// Level 1: Short vibration
Vibration.vibrate(duration: 200);

// Level 3: Strong pattern
Vibration.vibrate(pattern: [0, 300, 100, 300]);
```

### **4. Sound Alert**
Play sound notification untuk level 2 & 3:
```dart
import 'package:audioplayers/audioplayers.dart';

final player = AudioPlayer();
await player.play(AssetSource('sounds/alert.mp3'));
```

### **5. Parental Control PIN**
Untuk level 1, tambah opsi "Enter PIN to Dismiss":
```dart
// Parent bisa set PIN untuk bypass alert
```

---

## 📝 Summary

✅ **Response API simplified:** Hanya return `nsfw_level` (0-3) dan `status`

✅ **Full-screen notification:** Tampilan immersive dengan desain berbeda per level

✅ **Auto-trigger:** Listener otomatis menampilkan alert saat deteksi level > 0

✅ **User-friendly:** Level 1 bisa diabaikan, Level 2/3 harus tutup app

✅ **Responsive:** Animasi smooth dengan fade transition

---

## 🐛 Troubleshooting

### Problem: "Alert tidak muncul"
**Solution:**
1. Check console log: apakah API return `nsfw_level` dengan benar?
2. Pastikan `latestNsfwDetection` di-trigger:
   ```dart
   print('Value: ${_screenshotService.latestNsfwDetection.value}');
   ```
3. Pastikan `ever()` listener sudah dipanggil di `initState()`

### Problem: "Alert muncul berkali-kali"
**Solution:**
Reset detection setelah showing:
```dart
Future.delayed(const Duration(milliseconds: 500), () {
  _screenshotService.latestNsfwDetection.value = null;
});
```

### Problem: "Status bar masih terlihat"
**Solution:**
Pastikan `SystemChrome.setEnabledSystemUIMode()` dipanggil di `initState()`:
```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
```

---

## 📞 Contact

Jika ada pertanyaan atau bug, silakan buka issue di repository atau hubungi developer.

**Happy Coding! 🚀**
