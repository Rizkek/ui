# 🎬 Demo dengan Monitoring Simulation

Untuk melihat cara kerja monitoring:

## 📍 Lokasi Demo Screen
```
e:\coding\reflvy_service\zikri\lib\views\screens\demo\risk_detection_demo_screen.dart
```

## 🎮 Cara Menggunakan Demo

### 1. **Tampilan Overview** (Tab Pertama)
- ✅ Lihat statistik deteksi
- ✅ Lihat risk level examples
- ✅ Lihat riwayat deteksi
- ✅ Lihat fitur-fitur sistem
- ✅ Click FAB "Demo Popup" untuk test popup

### 2. **Live Monitoring Simulation** (Akan ditambahkan)

Karena demo screen menggunakan dummy data statis, fitur monitoring akan ditampilkan sebagai:

#### Opsi A: **Animated Monitoring Card**
Card yang menunjukkan:
- Status: Monitoring ON/OFF
- Currently Scanning: [App Name]
- Animation pulse saat scanning
- Recent Detection Feed (real-time style)

#### Opsi B: **Manual Trigger Buttons**
Buttons untuk simulate detection:
- "Trigger High Risk" → Auto show popup
- "Trigger Medium Risk" → Show warning  
- "Trigger Low Risk" → Show snackbar
- Each akan update statistics real-time

#### Opsi C: **Simple Play/Pause**
- Button "Start Monitoring"
- Animation menunjukkan scanning apps
- Random detection muncul setiap 2-3 detik
- Statistics update otomatis

## 💡 Recommended: Opsi B (Manual Trigger)

Paling mudah untuk demonstrasi tanpa perlu logic kompleks:

```dart
// Tambahan di bawah Feature Cards:

_buildSectionTitle('Simulasi Deteksi  Manual'),
const SizedBox(height: 12),

// Trigger Buttons
Row(
  children: [
    Expanded(
      child: _buildTriggerButton(
        'High Risk',
        Icons.dangerous,
        Colors.red,
        () => _simulateHighRisk(),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _buildTriggerButton(
        'Medium',
        Icons.warning_amber,
        Colors.orange,
        () => _simulateMediumRisk(),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _buildTriggerButton(
        'Low',
        Icons.info,
        Colors.yellow.shade700,
        () => _simulateLowRisk(),
      ),
    ),
  ],
),
```

## 🔧 Yang Perlu Ditambahkan

### Method untuk Simulate:
```dart
void _simulateHighRisk() {
  setState(() {
    highRiskCount++;
    totalDetections++;
  });
  
  // Show popup otomatis
  _showDemoPopup();
  
  // Add to feed
  detectionFeed.insert(0, {
    'app': 'Demo Adult App',
    'risk': 'high',
    'time': 'Baru saja',
  });
}

void _simulateMediumRisk() {
  setState(() {
    mediumRiskCount++;
    totalDetections++;
  });
  
  Get.snackbar(
    'Medium Risk Detected',
    'Konten sugestif terdeteksi',
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.orange,
    colorText: Colors.white,
    icon: Icon(Icons.warning_amber, color: Colors.white),
  );
}

void _simulateLowRisk() {
  setState(() {
    lowRiskCount++;
    totalDetections++;
  });
  
  Get.snackbar(
    'Low Risk Warning',
    'Stranger chat detected',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.yellow.shade700,
    colorText: Colors.white,
  );
}
```

## ✨ Hasil yang Didapat

User bisa:
1. ✅ Click button untuk simulate detection
2. ✅ Lihat statistics update real-time
3. ✅ Lihat popup muncul untuk high/medium risk
4. ✅ Lihat snackbar untuk low risk
5. ✅ Understanding flow monitoring tanpa perlu actual service

Apakah Anda ingin saya implement Opsi B (Manual Trigger Buttons) ini?
