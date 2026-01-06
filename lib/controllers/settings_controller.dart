import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Observables
  final RxBool isProtectionEnabled = true.obs;
  final RxBool blockSocialMedia = false.obs;
  final RxList<String> blockedApps = <String>[].obs;

  // Sensitivity: 1 (Low), 2 (Medium), 3 (High)
  final RxInt sensitivityLevel = 1.obs;

  void toggleProtection(bool value) {
    isProtectionEnabled.value = value;
    // Save to storage...
  }

  void toggleSocialMediaBlock(bool value) {
    blockSocialMedia.value = value;
    if (value) {
      blockedApps.addAll(['Instagram', 'TikTok', 'Twitter', 'X', 'Facebook']);
    } else {
      blockedApps.removeWhere(
        (app) =>
            ['Instagram', 'TikTok', 'Twitter', 'X', 'Facebook'].contains(app),
      );
    }
    blockedApps.refresh();
  }

  void setSensitivity(int level) {
    sensitivityLevel.value = level;
  }

  void addBlockedApp(String appName) {
    if (!blockedApps.contains(appName)) {
      blockedApps.add(appName);
    }
  }

  void removeBlockedApp(String appName) {
    blockedApps.remove(appName);
  }

  bool isAppBlocked(String appName) {
    // Case insensitive check
    return blockedApps.any(
      (blocked) => blocked.toLowerCase() == appName.toLowerCase(),
    );
  }
}
