# Risk Detection & Content Blocking System

## 📋 Overview

Sistem deteksi risiko konten dengan 3 level (High, Medium, Low), popup block otomatis, content triggers, psychoeducation, dan PIN protection untuk mode orang tua.

## 🎯 Fitur Utama

### 1. **Risk Levels**
- **High Risk**: Auto block + Popup urgent + Notifikasi ke orang tua
- **Medium Risk**: Popup warning + Notifikasi ke orang tua  
- **Low Risk**: Peringatan ringan tanpa block

### 2. **Popup Block Otomatis**
- Muncul otomatis saat konten berisiko terdeteksi
- Tidak bisa di-dismiss tanpa action
- Menampilkan detail deteksi dan content triggers
- Button untuk psychoeducation

### 3. **Content Triggers**
- Database keywords untuk deteksi konten
- Kategori: Konten Dewasa, Kekerasan, Perjudian, dll.
- Support custom triggers dari orang tua
- Real-time detection dari text dan URL

### 4. **Psychoeducation**
- Penjelasan mengapa konten berbahaya
- Dampak psikologis
- Langkah yang harus dilakukan
- Panduan untuk orang tua
- Sumber bantuan profesional

### 5. **PIN Protection**
- PIN 4-6 digit untuk override deteksi
- Temporary disable monitoring (1 jam)
- Log setiap PIN usage untuk review orang tua

## 🚀 Quick Start

### 1. Initialize Controllers

```dart
import 'package:get/get.dart';
import 'package:zikri/controllers/detection_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Detection Controller
  Get.put(DetectionController());
  
  runApp(MyApp());
}
```

### 2. Setup Parent Settings

```dart
import 'package:zikri/models/parent_settings.dart';
import 'package:zikri/controllers/detection_controller.dart';

void setupParentMode() {
  final controller = Get.find<DetectionController>();
  
  final settings = ParentSettings(
    userId: 'parent_user_id',
    isParentModeEnabled: true,
    pin: '1234', // Set PIN orang tua
    blockPopupEnabled: true,
    highRiskAutoBlock: true,
    mediumRiskNotify: true,
    lowRiskWarning: true,
  );
  
  controller.updateParentSettings(settings);
}
```

### 3. Detect Content

```dart
import 'package:zikri/controllers/detection_controller.dart';

Future<void> checkContent(String appName, String content) async {
  final controller = Get.find<DetectionController>();
  
  await controller.handleDetection(
    appName: appName,
    packageName: 'com.example.app',
    textContent: content,
    context: context, // BuildContext untuk show popup
  );
}
```

## 📝 Usage Examples

### Example 1: Monitor Browser URL

```dart
import 'package:zikri/services/monitoring/content_trigger_service.dart';

void monitorBrowserUrl(String url) async {
  final detection = await ContentTriggerService.analyzeUrl(
    url,
    'Chrome Browser',
  );
  
  if (detection != null) {
    // Content berisiko terdeteksi
    print('Risk Level: ${detection.riskLevel.name}');
    print('Triggers: ${detection.triggers.join(', ')}');
    
    // Handle dengan controller
    final controller = Get.find<DetectionController>();
    await controller.handleDetection(
      appName: 'Chrome',
      packageName: 'com.android.chrome',
      url: url,
      context: context,
    );
  }
}
```

### Example 2: Monitor Chat Messages

```dart
void monitorChatMessage(String message) async {
  final detection = await ContentTriggerService.analyzeText(
    message,
    'WhatsApp',
    'com.whatsapp',
  );
  
  if (detection != null) {
    // Show warning atau block
    final controller = Get.find<DetectionController>();
    await controller.handleDetection(
      appName: 'WhatsApp',
      packageName: 'com.whatsapp',
      textContent: message,
      context: context,
    );
  }
}
```

### Example 3: Check App Package Name

```dart
void checkAppRisk(String packageName) {
  // Check if app is blacklisted
  if (ContentTriggerService.isBlacklistedApp(packageName)) {
    print('⛔ App is blacklisted!');
    return;
  }
  
  // Analyze package name risk
  final riskLevel = ContentTriggerService.analyzePackageName(packageName);
  print('Risk Level: ${riskLevel.name}');
}
```

### Example 4: Show Popup Manually

```dart
import 'package:zikri/views/widgets/content_block_popup.dart';
import 'package:zikri/models/risk_detection.dart';

void showBlockPopup(BuildContext context) {
  final detection = RiskDetection(
    id: '1',
    appName: 'Instagram',
    packageName: 'com.instagram.android',
    riskLevel: RiskLevel.high,
    detectedContent: 'Konten dewasa terdeteksi',
    detectedAt: DateTime.now(),
    isBlocked: true,
    triggers: ['adult', 'explicit'],
  );
  
  ContentBlockPopup.show(
    context: context,
    detection: detection,
    parentSettings: controller.parentSettings.value,
    onPsychoeducationTap: () {
      Get.to(() => PsychoeducationScreen(detection: detection));
    },
    onPinEntered: (pin) async {
      print('PIN entered: $pin');
    },
  );
}
```

### Example 5: Add Custom Triggers

```dart
import 'package:zikri/services/monitoring/content_trigger_service.dart';
import 'package:zikri/models/risk_detection.dart';

void addCustomContentTriggers() {
  // Add custom trigger
  ContentTriggerService.addCustomTrigger(
    ContentTrigger(
      keyword: 'custom_keyword',
      riskLevel: RiskLevel.high,
      category: 'Custom Category',
    ),
  );
  
  // Get all triggers by category
  final triggers = ContentTriggerService.getTriggersByCategory('Konten Dewasa');
  print('Found ${triggers.length} triggers');
  
  // Get statistics
  final stats = ContentTriggerService.getTriggerStatistics();
  print('High: ${stats['high']}, Medium: ${stats['medium']}, Low: ${stats['low']}');
}
```

## 🎨 UI Components

### Parent Settings Screen

Navigate ke settings untuk konfigurasi:

```dart
import 'package:zikri/views/screens/profile/parent_settings_screen.dart';

// Navigate
Get.to(() => const ParentSettingsScreen());
```

Fitur yang tersedia:
- Toggle Mode Orang Tua
- Setup/Change PIN
- Enable/Disable Popup Block
- Configure risk level behaviors
- View statistics

### Psychoeducation Screen

Show edukasi kepada anak:

```dart
import 'package:zikri/views/screens/education/psychoeducation_screen.dart';

Get.to(() => PsychoeducationScreen(detection: detection));
```

Konten:
- Penjelasan bahaya konten
- Dampak psikologis
- Langkah yang harus dilakukan
- Panduan untuk orang tua
- Sumber bantuan

## 📊 Statistics & Monitoring

```dart
final controller = Get.find<DetectionController>();

// Get today's statistics
print('Detected today: ${controller.detectedToday.value}');
print('Blocked today: ${controller.blockedToday.value}');
print('High risk: ${controller.highRiskCount.value}');
print('Medium risk: ${controller.mediumRiskCount.value}');
print('Low risk: ${controller.lowRiskCount.value}');

// Get detection history
final history = controller.detectionHistory;
print('Total detections: ${history.length}');

// Get by risk level
final highRisk = controller.getDetectionsByRiskLevel(RiskLevel.high);
print('High risk detections: ${highRisk.length}');

// Get by date range
final today = DateTime.now();
final startOfDay = DateTime(today.year, today.month, today.day);
final endOfDay = startOfDay.add(const Duration(days: 1));
final todayDetections = controller.getDetectionsByDateRange(startOfDay, endOfDay);
```

## 🔧 Configuration

### Default Risk Behaviors

**High Risk:**
- ✅ Auto block content
- ✅ Show popup
- ✅ Send urgent notification to parent
- ✅ Log to database

**Medium Risk:**
- ⚠️ Show warning popup
- ✅ Send notification to parent
- ✅ Log to database
- ❌ No auto block

**Low Risk:**
- ℹ️ Show snackbar warning
- ❌ No popup
- ❌ No notification
- ✅ Log to database

### Customization

Orang tua dapat mengubah behavior setiap risk level di Parent Settings Screen.

## 🔐 Security Features

### PIN Protection
- 4-6 digit numeric PIN
- Required untuk temporary disable detection
- Logged untuk review orang tua
- Auto re-enable setelah 1 jam

### Content Triggers
- Pre-defined keywords database
- Support custom triggers
- Export/import untuk backup
- Reset ke default jika needed

## 📱 Integration dengan Existing Code

### Dashboard Integration

```dart
// Di dashboard page, show risk statistics
Obx(() {
  final controller = Get.find<DetectionController>();
  return _buildRiskSummary(
    high: controller.highRiskCount.value,
    medium: controller.mediumRiskCount.value,
    low: controller.lowRiskCount.value,
  );
});
```

### Monitoring Service Integration

```dart
// Di monitoring service, call detection saat app usage detected
class AppMonitoringService {
  Future<void> onAppDetected(String packageName, String appName) async {
    // Check risk level
    final riskLevel = ContentTriggerService.analyzePackageName(packageName);
    
    if (riskLevel != RiskLevel.low) {
      // Create detection
      final detection = RiskDetection(
        id: DateTime.now().toString(),
        appName: appName,
        packageName: packageName,
        riskLevel: riskLevel,
        detectedContent: 'App dengan risiko ${riskLevel.name}',
        detectedAt: DateTime.now(),
        triggers: [],
      );
      
      // Handle detection
      final controller = Get.find<DetectionController>();
      await controller.handleDetection(
        appName: appName,
        packageName: packageName,
        context: navigatorKey.currentContext,
      );
    }
  }
}
```

## 🐛 Debugging

Enable debug logs:

```dart
// Di main.dart
void main() {
  // Set to true untuk debug mode
  debugPrint('🔍 Detection system initialized');
  
  Get.put(DetectionController());
}
```

Logs akan menunjukkan:
- ✅ Detection events
- 🚨 Risk level alerts
- 📧 Parent notifications
- 🔓 PIN overrides
- 💾 Database saves

## 📦 Database Schema (TODO)

Future improvement: Save to Supabase

```sql
-- detections table
CREATE TABLE detections (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  app_name TEXT,
  package_name TEXT,
  risk_level TEXT, -- 'high', 'medium', 'low'
  detected_content TEXT,
  is_blocked BOOLEAN,
  triggers TEXT[], -- array of trigger keywords
  detected_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- parent_settings table
CREATE TABLE parent_settings (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id) UNIQUE,
  is_parent_mode_enabled BOOLEAN DEFAULT false,
  pin TEXT,
  block_popup_enabled BOOLEAN DEFAULT true,
  high_risk_auto_block BOOLEAN DEFAULT true,
  medium_risk_notify BOOLEAN DEFAULT true,
  low_risk_warning BOOLEAN DEFAULT true,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- pin_overrides log
CREATE TABLE pin_overrides (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  detection_id UUID REFERENCES detections(id),
  overridden_at TIMESTAMP DEFAULT NOW()
);
```

## ✅ Checklist Implementation

- [x] Risk Detection Model dengan 3 levels
- [x] Parent Settings Model dengan PIN
- [x] Content Trigger Service dengan keywords database
- [x] Popup Block Widget otomatis
- [x] Psychoeducation Screen
- [x] Detection Controller dengan auto-handling
- [x] Parent Settings Screen UI
- [x] Statistics tracking
- [x] PIN verification system
- [ ] Supabase integration (TODO)
- [ ] Push notification ke parent (TODO)
- [ ] Email notification (TODO)
- [ ] Export reports (TODO)

## 🎓 Best Practices

1. **Initialize early**: Put DetectionController in main.dart
2. **Pass BuildContext**: Always pass context untuk show popup
3. **Handle async properly**: Use await untuk detection
4. **Log everything**: Semua detection di-log untuk review
5. **Test PIN system**: Pastikan PIN validation works
6. **Monitor performance**: Detection should be fast (<100ms)

## 🆘 Support

Jika ada pertanyaan atau issue:
1. Check debug logs
2. Verify controller initialization
3. Test dengan sample detection
4. Review parent settings configuration
