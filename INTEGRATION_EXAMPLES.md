## 🔗 Quick Integration Example

### 1. Tambahkan ke Parent Dashboard

**File:** `lib/views/screens/dashboard/parent_dashboard_page.dart`

```dart
import '../../../controllers/detection_controller.dart';
import '../demo/risk_detection_demo_screen.dart';

// Di dalam ParentDashboardPage, tambahkan:

// Initialize controller di build method
final detectionController = Get.isRegistered<DetectionController>()
    ? Get.find<DetectionController>()
    : Get.put(DetectionController());

// Tambahkan Risk Summary Card setelah Summary Card
Positioned(
  bottom: -50,
  left: 24,
  right: 24,
  child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 15,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildRiskSummaryItem(
          Icons.dangerous_outlined,
          'High Risk',
          detectionController.highRiskCount.value.toString(),
          Colors.red,
        ),
        _buildRiskSummaryItem(
          Icons.warning_amber_rounded,
          'Medium',
          detectionController.mediumRiskCount.value.toString(),
          Colors.orange,
        ),
        _buildRiskSummaryItem(
          Icons.info_outline,
          'Low',
          detectionController.lowRiskCount.value.toString(),
          Colors.yellow.shade700,
        ),
      ],
    ),
  ),
),

// Method helper
Widget _buildRiskSummaryItem(
  IconData icon,
  String label,
  String value,
  Color color,
) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(height: 8),
      Text(
        value,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: const Color(0xFF1E293B),
        ),
      ),
      Text(
        label,
        style: GoogleFonts.raleway(
          color: const Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

// Tambahkan Quick Access Card
Container(
  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  child: Row(
    children: [
      Expanded(
        child: _buildQuickActionCard(
          'Settings',
          Icons.settings,
          Colors.blue,
          () => Get.to(() => const ParentSettingsScreen()),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _buildQuickActionCard(
          'Test Demo',
          Icons.science,
          Colors.purple,
          () => Get.to(() => const RiskDetectionDemoScreen()),
        ),
      ),
    ],
  ),
),

Widget _buildQuickActionCard(
  String label,
  IconData icon,
  Color color,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

### 2. Tambahkan Menu Item di Drawer/Navigation

```dart
// Di navigation drawer atau bottom nav
ListTile(
  leading: const Icon(Icons.shield_outlined, color: Color(0xFF4A90E2)),
  title: const Text('Risk Detection'),
  onTap: () {
    Get.to(() => const RiskDetectionDemoScreen());
  },
),

ListTile(
  leading: const Icon(Icons.psychology_outlined, color: Colors.green),
  title: const Text('Psychoeducation'),
  onTap: () {
    Get.to(() => PsychoeducationScreen(
      detection: RiskDetection(
        id: '1',
        appName: 'Sample',
        packageName: 'com.sample',
        riskLevel: RiskLevel.high,
        detectedContent: 'Sample',
        detectedAt: DateTime.now(),
        triggers: [],
      ),
    ));
  },
),
```

---

### 3. Hook ke Monitoring Service

**File:** `lib/services/monitoring/app_detection_service.dart`

```dart
import '../../controllers/detection_controller.dart';
import '../monitoring/content_trigger_service.dart';

class AppDetectionService {
  // Add to existing method
  Future<void> onAppOpened(String packageName, String appName) async {
    // Existing code...
    
    // NEW: Check risk level
    if (ContentTriggerService.isBlacklistedApp(packageName)) {
      final controller = Get.find<DetectionController>();
      await controller.handleDetection(
        appName: appName,
        packageName: packageName,
        context: Get.context,
      );
      return; // Block app
    }
    
    final riskLevel = ContentTriggerService.analyzePackageName(packageName);
    if (riskLevel == RiskLevel.high || riskLevel == RiskLevel.medium) {
      final controller = Get.find<DetectionController>();
      await controller.handleDetection(
        appName: appName,
        packageName: packageName,
        context: Get.context,
      );
    }
  }
}
```

---

### 4. Update Main.dart

```dart
import 'package:get/get.dart';
import 'controllers/detection_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase, etc...
  
  // NEW: Initialize Detection Controller
  Get.put(DetectionController());
  
  runApp(const MyApp());
}
```

---

### 5. Add to Child Dashboard (Optional)

**File:** `lib/views/screens/dashboard/dashboard_page.dart`

```dart
// Tambahkan Educational Banner
Container(
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.purple.shade400, Colors.blue.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Row(
    children: [
      const Icon(Icons.psychology_outlined, color: Colors.white, size: 32),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lindungi Dirimu!',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Pelajari tentang keamanan digital',
              style: GoogleFonts.raleway(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        icon: const Icon(Icons.arrow_forward, color: Colors.white),
        onPressed: () {
          // Navigate to psychoeducation
        },
      ),
    ],
  ),
),
```

---

### 6. Test Flow

**Recommended Testing Flow:**

1. **Setup Parent Mode**
```dart
// Go to Parent Settings
Get.to(() => const ParentSettingsScreen());

// Enable Parent Mode
// Set PIN (e.g., "1234")
// Configure risk levels
```

2. **Test Detection**
```dart
// Go to Demo Screen
Get.to(() => const RiskDetectionDemoScreen());

// Try each test:
// - High Risk Detection
// - Medium Risk Detection
// - Low Risk Detection
// - URL Detection
// - Text Detection
```

3. **Test PIN Override**
```dart
// Trigger high risk detection
// Click "Nonaktifkan dengan PIN"
// Enter PIN
// Verify temporary disable works
```

4. **Review Statistics**
```dart
// Check dashboard
// Should show detection counts
// Check history in demo screen
```

---

### 7. Sample Integration in Existing Screen

**Example: Add to Monitoring Screen**

```dart
// lib/views/screens/monitoring/monitoring_screen.dart

// Add import
import '../../demo/risk_detection_demo_screen.dart';

// Add FAB or button
floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    Get.to(() => const RiskDetectionDemoScreen());
  },
  icon: const Icon(Icons.science),
  label: const Text('Test Detection'),
  backgroundColor: const Color(0xFF4A90E2),
),
```

---

### 8. Custom Alert for High Risk

```dart
// Example: Custom handling untuk specific app
Future<void> handleInstagramDetection() async {
  final controller = Get.find<DetectionController>();
  
  final detection = RiskDetection(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    appName: 'Instagram',
    packageName: 'com.instagram.android',
    riskLevel: RiskLevel.medium,
    detectedContent: 'Social media dengan potensi konten tidak pantas',
    detectedAt: DateTime.now(),
    isBlocked: false,
    triggers: ['social', 'media'],
  );
  
  // Add to history
  controller.detectionHistory.insert(0, detection);
  
  // Show custom dialog
  if (controller.parentSettings.value?.mediumRiskNotify == true) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Peringatan Instagram'),
          ],
        ),
        content: Text(
          'Instagram terdeteksi. Harap berhati-hati dengan konten yang Anda lihat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Mengerti'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.to(() => PsychoeducationScreen(detection: detection));
            },
            child: Text('Pelajari Lebih Lanjut'),
          ),
        ],
      ),
    );
  }
}
```

---

### 9. Batch Test Script

```dart
// For testing multiple detections
Future<void> runBatchTest(BuildContext context) async {
  final controller = Get.find<DetectionController>();
  
  final tests = [
    {'app': 'Test High Risk', 'content': 'porn xxx adult'},
    {'app': 'Test Medium Risk', 'content': 'gambling casino bet'},
    {'app': 'Test Low Risk', 'content': 'stranger chat'},
  ];
  
  for (var test in tests) {
    await controller.handleDetection(
      appName: test['app']!,
      packageName: 'com.test',
      textContent: test['content']!,
      context: context,
    );
    
    await Future.delayed(Duration(seconds: 2));
  }
  
  Get.snackbar(
    'Test Complete',
    'Generated ${tests.length} test detections',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green,
    colorText: Colors.white,
  );
}
```

---

### 10. Export Data (Future Feature)

```dart
// Example: Export detection history to CSV
Future<void> exportDetectionHistory() async {
  final controller = Get.find<DetectionController>();
  
  String csv = 'Timestamp,App,Risk Level,Content,Blocked\n';
  
  for (var detection in controller.detectionHistory) {
    csv += '${detection.detectedAt},'
           '${detection.appName},'
           '${detection.riskLevel.name},'
           '"${detection.detectedContent}",'
           '${detection.isBlocked}\n';
  }
  
  // Save to file...
  print('CSV Data:\n$csv');
}
```

---

## 🎯 Integration Checklist

- [ ] Initialize DetectionController in main.dart
- [ ] Add risk summary to parent dashboard
- [ ] Add menu items for navigation
- [ ] Hook detection to monitoring service
- [ ] Test all three risk levels
- [ ] Configure parent settings
- [ ] Test PIN override functionality
- [ ] Verify statistics display
- [ ] Test psychoeducation screen flow
- [ ] Review detection history
- [ ] Test popup dismiss behavior
- [ ] Verify notifications (when implemented)

---

## 🚀 Ready to Deploy!

Semua komponen sudah ready dan dapat langsung digunakan. Silakan test dengan demo screen terlebih dahulu sebelum integrate ke production flow.
