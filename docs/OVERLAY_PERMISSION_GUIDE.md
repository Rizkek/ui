# 📱 Panduan Overlay Permission - SYSTEM_ALERT_WINDOW

## ⚠️ Masalah: Toggle Permission Tidak Bisa Diklik

### **Penyebab:**
Pada Android 6.0 (API 23) ke atas, permission `SYSTEM_ALERT_WINDOW` adalah **Special Permission** yang tidak bisa langsung granted melalui toggle di Settings → Apps → Permissions.

Permission ini harus **di-request secara programmatic** dari dalam aplikasi menggunakan `Settings.ACTION_MANAGE_OVERLAY_PERMISSION` intent.

---

## ✅ Solusi yang Sudah Diterapkan

### **1. Request Permission Otomatis saat Buka MonitoringScreen**

File: `monitoring_screen.dart`

```dart
Future<void> _checkPermissions() async {
  // ... permissions lain ...
  
  // Check dan request System Alert Window permission
  Future.delayed(const Duration(milliseconds: 300), () async {
    if (await Permission.systemAlertWindow.isDenied) {
      if (mounted) {
        _showOverlayPermissionDialog(); // ⬅️ Tampilkan dialog
      }
    }
  });
}
```

### **2. Dialog Informasi + Auto-Request**

```dart
void _showOverlayPermissionDialog() {
  Get.dialog(
    AlertDialog(
      title: const Text('🔔 Izin Tampil di Atas Aplikasi Lain'),
      content: const Text(
        'Aplikasi memerlukan izin "Display over other apps" untuk menampilkan alert NSFW...\n\n'
        'Langkah-langkah:\n'
        '1. Klik "Aktifkan" di bawah\n'
        '2. Cari "Reflvy" dalam daftar\n'
        '3. Aktifkan toggle "Permit drawing over other apps"\n'
        '4. Kembali ke aplikasi ini',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Nanti'),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            final status = await Permission.systemAlertWindow.request(); // ⬅️ Request permission
            
            if (status.isGranted) {
              Get.snackbar(
                '✅ Berhasil',
                'Izin overlay telah diaktifkan',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } else {
              Get.snackbar(
                'Aktifkan Izin',
                'Cari "Reflvy" dan aktifkan "Permit drawing over other apps"',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            }
          },
          child: const Text('Aktifkan'),
        ),
      ],
    ),
  );
}
```

---

## 🔧 Cara Kerja

### **Flow Permission Request:**

```
User buka MonitoringScreen
    ↓
_checkPermissions() dipanggil
    ↓
Cek: await Permission.systemAlertWindow.isDenied
    ↓ (jika belum granted)
Tampilkan dialog penjelasan
    ↓
User klik "Aktifkan"
    ↓
await Permission.systemAlertWindow.request()
    ↓ (membuka Settings otomatis)
System Settings → Special app access → Display over other apps
    ↓
User cari "Reflvy" dan toggle ON
    ↓
Kembali ke app
    ↓
Permission granted ✅
```

---

## 📋 Manual Steps untuk User

Jika user ingin mengaktifkan manual tanpa dialog:

### **Android 10+ (One UI, MIUI, ColorOS, dll):**
1. Buka **Settings** → **Apps**
2. Cari **"Reflvy"** atau **"fitur_deteksi_gambar_ai"**
3. Tap **"Special permissions"** atau **"Advanced"**
4. Pilih **"Display over other apps"** / **"Appear on top"**
5. **Toggle ON** → "Permit drawing over other apps"

### **Stock Android / Pixel:**
1. Settings → **Apps & notifications**
2. **Special app access**
3. **Display over other apps**
4. Cari **Reflvy** → Toggle **ON**

---

## 🧪 Testing

### **Cara Test Permission:**

```dart
// Cek status permission
bool hasOverlayPermission = await Permission.systemAlertWindow.isGranted;
print('Overlay permission: $hasOverlayPermission');

// Test bisa tampil overlay atau tidak
if (hasOverlayPermission) {
  // Tampilkan NsfwAlertScreen
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, _, __) => NsfwAlertScreen(level: 2),
      opaque: false,
    ),
  );
}
```

### **Expected Result:**
- ✅ Dialog muncul saat buka MonitoringScreen pertama kali
- ✅ Klik "Aktifkan" → Redirect ke Settings
- ✅ Toggle "Permit drawing over other apps" bisa diklik
- ✅ Setelah aktif, NSFW alert bisa muncul di atas app lain

---

## 🐛 Troubleshooting

### **Problem: Toggle masih tidak bisa diklik**

**Solusi:**
1. Pastikan `permission_handler` versi terbaru:
   ```yaml
   # pubspec.yaml
   permission_handler: ^11.0.1
   ```

2. Pastikan AndroidManifest.xml sudah ada:
   ```xml
   <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
   ```

3. Rebuild aplikasi:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### **Problem: Permission granted tapi overlay tidak muncul**

**Cek:**
- Apakah `OverlayService.kt` sudah benar?
- Apakah service sudah declared di manifest?
- Log error di Logcat: `adb logcat | grep Reflvy`

---

## 📚 Reference

- [Android Docs - SYSTEM_ALERT_WINDOW](https://developer.android.com/reference/android/Manifest.permission#SYSTEM_ALERT_WINDOW)
- [permission_handler Package](https://pub.dev/packages/permission_handler)
- [Flutter Overlay Tutorial](https://docs.flutter.dev/platform-integration/android/permissions)

---

## ✨ Summary

Permission `SYSTEM_ALERT_WINDOW` sekarang:
- ✅ Auto-request saat buka MonitoringScreen
- ✅ Ada dialog penjelasan user-friendly
- ✅ Direct link ke Settings
- ✅ Feedback snackbar setelah granted
- ✅ Toggle di Settings sudah bisa diklik

**Next Step:** Test di real device dan pastikan NSFW alert muncul saat terdeteksi!
