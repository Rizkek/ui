# 🔄 NSFW Monitoring Flow - Real API Integration

## 📋 Overview

Sistem monitoring NSFW yang terintegrasi dengan API `/api/detectnsfw` untuk mendeteksi konten berbahaya secara real-time dengan interval 5 detik.

---

## 🔁 **Main Loop Flow**

```
┌─────────────────────────────────────────────────────┐
│  START MONITORING                                    │
│  User klik "START MONITORING" di MonitoringScreen   │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│  PERMISSION CHECK                                    │
│  1. Screen Capture (MediaProjection)                │
│  2. Overlay (SYSTEM_ALERT_WINDOW)                   │
│  3. Usage Stats (untuk detect app)                  │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│  TIMER START - 5 Second Interval                    │
│  Timer.periodic(Duration(seconds: 5), ...)          │
└──────────────────┬──────────────────────────────────┘
                   │
         ┌─────────┴─────────┐
         │                   │
         ▼                   │ (LOOP)
┌─────────────────────┐      │
│  CHECK IF PAUSED    │      │
│  isPaused.value?    │      │
└──────┬──────────────┘      │
       │                     │
       ├─ YES → Skip ────────┘
       │
       ├─ NO → Continue
       │
       ▼
┌─────────────────────────────────────────────────────┐
│  STEP 1: DETECT CURRENT APP                         │
│  UsageStatsManager → getCurrentApp()                │
│  Result: "TikTok", "Instagram", "Chrome", etc.      │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│  STEP 2: CAPTURE SCREENSHOT                         │
│  MediaProjection → captureFrame()                   │
│  Result: Uint8List (PNG bytes)                      │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│  STEP 3: SEND TO API                                │
│  POST /api/detectnsfw                               │
│  Headers: Authorization: Bearer <firebase_token>    │
│  Body:                                              │
│    - image: <screenshot.png>                        │
│    - application: "TikTok"                          │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│  STEP 4: PROCESS API RESPONSE                       │
│  {                                                   │
│    "nsfw_level": 0-3,                               │
│    "status": "success"                              │
│  }                                                   │
└──────────────────┬──────────────────────────────────┘
                   │
         ┌─────────┴─────────┐
         │                   │
         ▼                   ▼
    nsfw_level = 0      nsfw_level > 0
    (SAFE)              (NSFW DETECTED!)
         │                   │
         │                   ▼
         │         ┌──────────────────────┐
         │         │  PAUSE MONITORING    │
         │         │  isPaused = true     │
         │         └─────────┬────────────┘
         │                   │
         │                   ▼
         │         ┌──────────────────────────────────┐
         │         │  SHOW POPUP INTERVENTION         │
         │         │  - Level 1: LOW (kuning)         │
         │         │  - Level 2: MEDIUM (orange)      │
         │         │  - Level 3: HIGH (merah)         │
         │         └─────────┬────────────────────────┘
         │                   │
         │                   ▼
         │         ┌──────────────────────────────────┐
         │         │  USER ACTION                     │
         │         │  1. "Abaikan" (LOW only)         │
         │         │  2. "Tutup Aplikasi" (all levels)│
         │         └─────────┬────────────────────────┘
         │                   │
         │                   ▼
         │         ┌──────────────────────────────────┐
         │         │  RESUME MONITORING               │
         │         │  isPaused = false                │
         │         └─────────┬────────────────────────┘
         │                   │
         └───────────────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  WAIT 5 SECONDS     │
         │  (Timer automatic)  │
         └─────────┬───────────┘
                   │
                   └──────────> REPEAT (LOOP)
```

---

## ⏱️ **Timer Behavior - PENTING!**

### **Karakteristik Timer:**

```dart
// Timer periodic 5 detik
_timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
  await _captureAndSave(); // Capture & process
});
```

### **Flow dengan Pause:**

```
Timer Tick #1 (0s)
  ↓
Capture → API → Level 0 (Safe)
  ↓
Timer Tick #2 (5s) ← Otomatis setelah 5 detik
  ↓
Capture → API → Level 2 (Medium)
  ↓
isPaused = TRUE ← PAUSE monitoring
Popup muncul
  ↓
... User baca popup (10 detik) ...
  ↓
User klik "Tutup Aplikasi"
  ↓
isPaused = FALSE ← RESUME monitoring
  ↓
Timer Tick #3 (5s setelah resume)
  ↓
Capture → API → ...
```

### **Saat Paused:**

```dart
Future<void> _captureAndSave() async {
  // ✅ Jika sedang pause, SKIP capture
  if (isPaused.value) {
    print('⏸️ Monitoring paused (popup is showing), skipping capture');
    return; // Langsung return, tidak proses apapun
  }
  
  // ... lanjut proses capture & API call ...
}
```

**Artinya:**
- Timer tetap berjalan setiap 5 detik
- TAPI jika `isPaused = true`, fungsi langsung return tanpa capture
- Setelah popup ditutup (`isPaused = false`), tick berikutnya akan capture lagi

---

## 🌐 **API Integration Details**

### **Endpoint:**
```
POST http://10.7.4.100:3000/api/detectnsfw
```

### **Request:**
```
Headers:
  Authorization: Bearer <firebase_id_token>
  Content-Type: multipart/form-data

Body (multipart):
  - image: <file> (screenshot.png)
  - application: <string> (TikTok, Instagram, etc.)
```

### **Response:**
```json
{
  "nsfw_level": 0,  // 0=Safe, 1=Low, 2=Medium, 3=High
  "status": "success"
}
```

### **Backend Flow:**
```
1. Terima image + application
2. Forward ke Python ML Service (127.0.0.1:5000/detect)
3. Classify NSFW level (0-3)
4. Jika level > 0: Save ke Firestore (nsfw_stats collection)
5. Return {"nsfw_level": X, "status": "success"}
```

---

## 🎨 **Popup Intervention Levels**

### **Level 0 (SAFE) - Hijau**
- ✅ Tidak ada popup
- ✅ Screenshot disimpan ke history
- ✅ Monitoring continue

### **Level 1 (LOW) - Kuning**
- ⚠️ Popup peringatan ringan
- 🔙 User **BISA** back (WillPopScope = true)
- 📱 Tombol: "Abaikan" & "Tutup Aplikasi"
- ⏯️ Monitoring pause sampai popup ditutup

### **Level 2 (MEDIUM) - Orange**
- ⚠️⚠️ Popup peringatan serius
- 🚫 User **TIDAK BISA** back (WillPopScope = false)
- 📱 Tombol: "Tutup Aplikasi" only
- ⏯️ Monitoring pause sampai popup ditutup

### **Level 3 (HIGH) - Merah**
- 🚨🚨🚨 Popup peringatan kritis
- 🚫 User **TIDAK BISA** back (WillPopScope = false)
- 📱 Tombol: "Tutup Aplikasi" only
- ⏯️ Monitoring pause sampai popup ditutup
- 🏠 App berbahaya OTOMATIS minimize ke home

---

## 📊 **State Management (GetX)**

```dart
// Observable variables
final RxBool isRecording = false.obs;      // Status monitoring
final RxBool isPaused = false.obs;         // Status pause (popup showing)
final RxInt screenshotCount = 0.obs;       // Jumlah screenshot
final RxString currentApp = 'Unknown'.obs; // App sedang dibuka
final RxList<Map> screenshots = [].obs;    // History screenshots

// State flow:
startMonitoring()
  → isRecording = true
  → isPaused = false

NSFW Detected
  → isPaused = true (PAUSE)

User tutup popup
  → isPaused = false (RESUME)

stopMonitoring()
  → isRecording = false
  → cancel timer
```

---

## 🔐 **Security & Authentication**

### **Firebase Auth Token:**
```dart
final user = FirebaseAuth.instance.currentUser;
final idToken = await user.getIdToken();

request.headers['Authorization'] = 'Bearer $idToken';
```

### **Backend Verification:**
```go
// middleware/auth.go
func AuthMiddleware() gin.HandlerFunc {
  return func(c *gin.Context) {
    tokenString := c.GetHeader("Authorization")
    // Verify Firebase ID token
    token, err := auth.VerifyIDToken(ctx, tokenString)
    // Set email to context
    c.Set("email", token.Claims["email"])
    c.Next()
  }
}
```

---

## 📂 **Data Flow & Storage**

### **1. Local Storage (Flutter - In-Memory):**
```dart
screenshots.add({
  'timestamp': DateTime.now(),
  'app_name': 'TikTok',
  'image_bytes': Uint8List,
  'size': 245678,
  'nsfw_level': 2,  // ← dari API response
});
```

### **2. Cloud Storage (Firestore):**
```
Collection: nsfw_stats
Document ID: emailpart_2025-11-07

{
  "user_id": "user@example.com",
  "date": "November 7, 2025",
  "grand_total": 15,
  "total_low": 3,
  "total_medium": 8,
  "total_high": 4,
  "app_counts": {
    "tiktok": {
      "total": 10,
      "low": 2,
      "medium": 5,
      "high": 3
    },
    "instagram": {
      "total": 5,
      "low": 1,
      "medium": 3,
      "high": 1
    }
  }
}
```

**Update Logic:**
- Level 0 (Safe): **TIDAK disimpan** ke Firestore
- Level 1-3: **Auto-increment** counters per app + grand total

---

## 🐛 **Error Handling**

### **API Call Timeout:**
```dart
final streamedResponse = await request.send().timeout(
  const Duration(seconds: 30),
  onTimeout: () {
    print('⏱️ API request timeout');
    throw TimeoutException('Request timeout');
  },
);
```

### **Null Response:**
```dart
if (nsfwLevel == null) {
  print('❌ Failed to get NSFW level from API');
  return; // Skip popup, continue monitoring
}
```

### **Network Error:**
```dart
try {
  // ... API call ...
} catch (e) {
  print('❌ Error sending to API: $e');
  return null; // Graceful fallback
}
```

---

## 🧪 **Testing Checklist**

- [ ] **Permission Flow:**
  - [ ] Screen capture permission request
  - [ ] Overlay permission dialog
  - [ ] Usage stats permission dialog

- [ ] **Monitoring Flow:**
  - [ ] Start monitoring → timer starts
  - [ ] Capture every 5 seconds
  - [ ] Detect current app correctly

- [ ] **API Integration:**
  - [ ] Screenshot sent to API
  - [ ] Auth token included
  - [ ] Response parsed correctly

- [ ] **Popup Behavior:**
  - [ ] Level 0: No popup
  - [ ] Level 1: Can dismiss/close
  - [ ] Level 2: Must close app
  - [ ] Level 3: Must close app + force minimize

- [ ] **Timer Pause/Resume:**
  - [ ] Monitoring pauses when popup shown
  - [ ] Timer skips capture when paused
  - [ ] Monitoring resumes after popup closed
  - [ ] Next capture happens 5s after resume

- [ ] **Statistics:**
  - [ ] Level 0: Not saved to Firestore ✅
  - [ ] Level 1-3: Saved with correct counters ✅
  - [ ] App-specific counters increment ✅

---

## 📱 **User Experience Flow**

```
User Login
  ↓
Dashboard → Tab "Monitoring"
  ↓
Permission dialogs (3x):
  1. "Allow screen recording?" → Start now
  2. "Display over other apps?" → Aktifkan
  3. "Usage access?" → Buka Settings
  ↓
User klik "START MONITORING"
  ↓
Status: 🔴 MONITORING AKTIF
Screenshot count: 0 → 1 → 2 → ...
Current app: TikTok
  ↓
(After 5 seconds)
Capture #1 → API → Level 0 (Safe) → No popup
  ↓
(After 5 seconds)
Capture #2 → API → Level 2 (Medium) → ⚠️ POPUP!
  ↓
"⚠️ Peringatan Konten Sedang
Terdeteksi konten berisiko sedang (Medium NSFW).
Aplikasi: TikTok"
  ↓
User klik "Tutup Aplikasi"
  ↓
TikTok minimize to home
Popup hilang
Monitoring RESUME
  ↓
(After 5 seconds)
Capture #3 → API → Level 0 (Safe) → Continue
  ↓
... LOOP terus ...
```

---

## 🚀 **Next Steps**

1. ✅ **Test API Integration:**
   - Pastikan backend running (Go + Python ML)
   - Cek Firebase Auth token valid
   - Verify Firestore write permissions

2. ✅ **Test Timer Pause/Resume:**
   - Monitor logs saat popup muncul
   - Pastikan capture skip saat `isPaused = true`
   - Verify next capture setelah resume

3. ✅ **Test dengan Real Apps:**
   - Buka TikTok → cek detection
   - Buka Instagram → cek detection
   - Cek app name detection akurat

4. ✅ **Monitor Performance:**
   - Battery usage
   - Memory usage (in-memory screenshots)
   - API response time

---

**Status:** ✅ Ready for Production Testing
**Last Updated:** November 7, 2025
