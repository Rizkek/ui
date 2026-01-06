# 🔐 2FA PIN APPROVAL SYSTEM - UI Testing Guide

## ✅ Implementasi Selesai!

Sistem 2FA PIN Approval untuk stop monitoring telah sepenuhnya diimplementasikan. Berikut adalah **bagian-bagian UI yang harus kamu cek**:

---

## 📱 DEVICE ANAK (Child Device)

### 1. **Monitoring Screen - Tombol "HENTIKAN MONITORING"**

**Lokasi:** `lib/views/screens/monitoring/monitoring_screen.dart`

**Cara Test:**

1. Buka aplikasi di device ANAK
2. Aktifkan monitoring dengan toggle "Monitoring dari Orang Tua" di halaman Profile
3. Tekan tombol **"HENTIKAN MONITORING"** (tombol merah besar)
4. Jika parental mode aktif, akan muncul dialog **"Menunggu Konfirmasi"**

**Yang Harus Dicek:**

- ✅ Tombol merah "HENTIKAN MONITORING" berfungsi
- ✅ Dialog waiting muncul dengan animasi loading (hourglass icon berputar)
- ✅ Teks: "Permintaan stop monitoring telah dikirim ke orang tua"
- ✅ Info box kuning: "Tunggu approval untuk melanjutkan"
- ✅ Countdown info: "Request akan otomatis dibatalkan dalam 5 menit"
- ✅ Tombol "Batal Permintaan" berfungsi untuk cancel request

**Screenshot Area:**

```
┌─────────────────────────────────────┐
│  🔴 [HENTIKAN MONITORING]           │  ← Tombol ini!
└─────────────────────────────────────┘
```

### 2. **Waiting for Approval Dialog (Device ANAK)**

**File:** `lib/views/widgets/waiting_for_parent_approval_dialog.dart`

**Tampilan Dialog:**

```
┌──────────────────────────────────────┐
│          ⏳ (loading animation)       │
│                                      │
│      Menunggu Konfirmasi             │
│                                      │
│  Permintaan stop monitoring telah    │
│  dikirim ke orang tua.               │
│                                      │
│  ⚠️ Tunggu approval untuk            │
│     melanjutkan                      │
│                                      │
│  Request akan otomatis dibatalkan    │
│  dalam 5 menit                       │
│                                      │
│      [Batal Permintaan]              │
└──────────────────────────────────────┘
```

**Behavior yang Harus Dicek:**

- ✅ Dialog TIDAK bisa ditutup dengan tap di luar dialog
- ✅ Loading animation berputar
- ✅ Status update otomatis ketika parent approve/reject:
  - **APPROVED**: Dialog tutup, muncul snackbar hijau "✅ Disetujui"
  - **REJECTED**: Dialog tutup, muncul snackbar merah "❌ Ditolak"
  - **TIMEOUT**: Dialog tutup, muncul snackbar orange "⏱️ Timeout"

---

## 👨‍👩‍👧 DEVICE ORANG TUA (Parent Device)

### 3. **Pending Requests Panel**

**Lokasi:** `lib/views/screens/parent/pending_requests_panel.dart`

**Cara Test:**

1. Buka aplikasi di device ORTU
2. Aktifkan "Mode Orang Tua" di Parent Settings
3. Ketika anak request stop monitoring, panel ini akan muncul OTOMATIS

**Tampilan Panel:**

```
┌──────────────────────────────────────┐
│  🔔  Permintaan Menunggu        [1]  │
│       1 permintaan perlu approval    │
│ ──────────────────────────────────── │
│                                      │
│  👤 Nama Anak                 ⏱️ 4m  │
│  Meminta stop monitoring             │
│                                      │
│  [Tolak]         [Approve]           │
│                                      │
└──────────────────────────────────────┘
```

**Yang Harus Dicek:**

- ✅ Panel muncul OTOMATIS ketika ada request baru
- ✅ Badge angka menunjukkan jumlah pending requests
- ✅ Timer countdown berjalan (dari 5m ke 0m)
- ✅ Tombol "Tolak" langsung reject request
- ✅ Tombol "Approve" membuka PIN Dialog
- ✅ Jika tidak ada pending requests, tampilkan empty state

**Empty State:**

```
┌──────────────────────────────────────┐
│          ✅ (icon besar)              │
│                                      │
│      Tidak Ada Permintaan            │
│                                      │
│  Semua permintaan telah diproses     │
└──────────────────────────────────────┘
```

### 4. **PIN Approval Dialog (Device ORTU)**

**File:** `lib/views/widgets/pin_approval_dialog.dart`

**Tampilan Dialog:**

```
┌──────────────────────────────────────┐
│          🔒 (lock icon)               │
│                                      │
│   Konfirmasi Stop Monitoring         │
│                                      │
│  👤 Nama Anak meminta stop           │
│     monitoring                       │
│                                      │
│  Masukkan PIN untuk konfirmasi:      │
│                                      │
│   [_] [_] [_] [_] [_] [_]            │
│   ↑ 6 kotak input PIN                │
│                                      │
│      [Tolak]    [Approve]            │
└──────────────────────────────────────┘
```

**Behavior yang Harus Dicek:**

- ✅ 6 kotak input PIN (obscured/hidden text)
- ✅ Auto-focus ke kotak berikutnya saat ketik
- ✅ Backspace pindah ke kotak sebelumnya
- ✅ Auto-submit ketika 6 digit sudah terisi
- ✅ Tombol "Approve" disabled sampai 6 digit terisi
- ✅ Verifikasi PIN dengan stored PIN di secure storage
- ✅ Jika PIN SALAH: Snackbar merah "❌ PIN Salah"
- ✅ Jika PIN BENAR: Request diapprove, dialog tutup
- ✅ Loading indicator muncul saat proses approve

**PIN Input Focus Flow:**

```
Ketik 1 → Pindah ke kotak 2 → Ketik 2 → Pindah ke kotak 3 → ...
Ketik 6 → AUTO SUBMIT!
```

---

## 🔄 FLOW LENGKAP YANG HARUS DITEST

### End-to-End Testing:

#### **Scenario 1: Normal Approval**

1. **ANAK**: Tap "HENTIKAN MONITORING" → Dialog waiting muncul
2. **ORTU**: Panel pending requests muncul otomatis → Tap "Approve"
3. **ORTU**: Dialog PIN muncul → Input 6 digit PIN yang BENAR
4. **ORTU**: Snackbar hijau "✅ Disetujui" muncul
5. **ANAK**: Dialog waiting otomatis tutup → Snackbar hijau "✅ Disetujui"
6. **ANAK**: Monitoring STOP (screenshot tidak lagi diambil)

#### **Scenario 2: Rejection**

1. **ANAK**: Tap "HENTIKAN MONITORING" → Dialog waiting muncul
2. **ORTU**: Panel pending requests muncul → Tap "Tolak"
3. **ORTU**: Request langsung ditolak
4. **ANAK**: Dialog waiting otomatis tutup → Snackbar merah "❌ Ditolak"
5. **ANAK**: Monitoring TETAP BERJALAN

#### **Scenario 3: Wrong PIN**

1. **ANAK**: Tap "HENTIKAN MONITORING" → Dialog waiting muncul
2. **ORTU**: Tap "Approve" → Dialog PIN muncul
3. **ORTU**: Input 6 digit PIN yang SALAH
4. **ORTU**: Snackbar merah "❌ PIN Salah" muncul
5. **ANAK**: Dialog waiting TETAP TERBUKA (masih menunggu)

#### **Scenario 4: Manual Cancel**

1. **ANAK**: Tap "HENTIKAN MONITORING" → Dialog waiting muncul
2. **ANAK**: Tap "Batal Permintaan"
3. **ANAK**: Dialog tutup → Snackbar "ℹ️ Dibatalkan"
4. **ORTU**: Request hilang dari pending panel

#### **Scenario 5: Timeout**

1. **ANAK**: Tap "HENTIKAN MONITORING" → Dialog waiting muncul
2. **ORTU**: TIDAK approve/reject selama 5 menit
3. **ANAK**: Dialog otomatis tutup → Snackbar orange "⏱️ Timeout"
4. **ORTU**: Request otomatis expired/hilang

---

## 📂 FILE-FILE BARU YANG DIBUAT

### Models:

- ✅ `lib/models/monitoring_request.dart` - Data model untuk request

### Services:

- ✅ `lib/services/monitoring/monitoring_request_service.dart` - Firestore CRUD operations

### Controllers:

- ✅ `lib/controllers/monitoring_approval_controller.dart` - Business logic untuk approval flow

### UI Widgets:

- ✅ `lib/views/widgets/waiting_for_parent_approval_dialog.dart` - Dialog untuk ANAK
- ✅ `lib/views/widgets/pin_approval_dialog.dart` - Dialog untuk ORTU

### UI Screens:

- ✅ `lib/views/screens/parent/pending_requests_panel.dart` - Panel pending requests

### Modified Files:

- ✅ `lib/views/screens/monitoring/monitoring_screen.dart` - Integrasi approval flow

---

## 🎯 TESTING CHECKLIST

### Functional Testing:

- [ ] Tombol "HENTIKAN MONITORING" memunculkan dialog waiting
- [ ] Dialog waiting menampilkan loading animation
- [ ] Pending requests muncul di parent device
- [ ] Timer countdown berjalan dengan benar
- [ ] PIN input auto-focus dan auto-submit
- [ ] PIN verification bekerja (salah vs benar)
- [ ] Approval berhasil menghentikan monitoring
- [ ] Rejection tidak menghentikan monitoring
- [ ] Cancel button berfungsi
- [ ] Timeout setelah 5 menit

### UI/UX Testing:

- [ ] Animasi smooth dan tidak lag
- [ ] Warna sesuai design (biru, merah, kuning)
- [ ] Typography readable (Outfit + Raleway fonts)
- [ ] Dialog tidak bisa ditutup dengan tap outside
- [ ] Snackbar muncul dengan pesan yang jelas
- [ ] Loading indicators muncul saat proses

### Real-time Sync Testing:

- [ ] Firestore listener bekerja (status update real-time)
- [ ] Multiple devices sync dengan benar
- [ ] Offline mode handling (connection lost)

---

## ⚙️ KONFIGURASI YANG DIPERLUKAN

### 1. **Parent PIN Setup**

Sebelum test, pastikan Parent PIN sudah diset:

```dart
// Di Parent Settings, set PIN dulu
await SecureStorageService().write('parent_pin', '123456');
await SecureStorageService().write('parental_mode', 'true');
```

### 2. **Firestore Rules**

Pastikan Firestore rules sudah allow read/write ke collection `monitoring_requests`:

```javascript
match /monitoring_requests/{requestId} {
  allow read, write: if request.auth != null;
}
```

### 3. **Firebase Project Setup**

- ✅ Firebase Auth enabled
- ✅ Firestore Database created
- ✅ `google-services.json` di folder `android/app/`

---

## 🚨 KNOWN ISSUES / TODO

### Current Limitations:

1. **FCM Notifications**: Belum implemented (parent device tidak dapat push notification)

   - Saat ini parent harus buka app untuk lihat pending requests
   - **Next Step**: Implement Firebase Cloud Messaging

2. **Cloud Functions**: Belum ada auto-trigger untuk send notification

   - Request creation tidak otomatis trigger notification
   - **Next Step**: Create Cloud Functions untuk auto-send FCM

3. **Parent-Child Linking**: Belum ada sistem link account parent-child

   - Saat ini menggunakan user ID yang sama (demo mode)
   - **Next Step**: Create account linking system

4. **Offline Handling**: Belum handle edge case offline
   - Request creation gagal jika tidak ada internet
   - **Next Step**: Add offline queue and retry mechanism

---

## 📝 CATATAN TAMBAHAN

### Architecture Pattern:

- **MVVM + Service Layer**: Controllers handle business logic, Services handle data operations
- **Reactive State Management**: GetX observables untuk real-time UI updates
- **Stream-based Communication**: Firestore listeners untuk cross-device sync

### Security:

- ✅ PIN stored di Secure Storage (encrypted)
- ✅ PIN verification di device, tidak dikirim ke server
- ✅ Request expiration untuk prevent replay attacks

### Performance:

- ✅ Efficient Firestore queries dengan composite indexes
- ✅ Stream subscriptions properly disposed
- ✅ Loading states untuk prevent double-tap

---

## 📞 PERTANYAAN?

Jika ada yang error atau tidak berfungsi:

1. Check Firestore console untuk lihat request documents
2. Check debug console untuk error messages
3. Verify parent PIN sudah diset dengan benar
4. Pastikan parental mode enabled di Parent Settings

---

**Happy Testing! 🎉**

Kalau ada yang kurang jelas atau error, langsung tanya ya!
