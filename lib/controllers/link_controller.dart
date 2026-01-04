import 'dart:math';
import 'package:get/get.dart';

class LinkedChild {
  final String id;
  final String name;
  final String email;
  final bool isOnline;
  final int alertsToday;
  final DateTime linkedAt;

  LinkedChild({
    required this.id,
    required this.name,
    required this.email,
    required this.isOnline,
    required this.alertsToday,
    required this.linkedAt,
  });
}

class LinkController extends GetxController {
  // Observable
  final RxList<LinkedChild> linkedChildren = <LinkedChild>[].obs;
  final RxString generatedCode = ''.obs;
  final RxBool isCodeActive = false.obs;
  final Rx<DateTime?> codeExpiresAt = Rx<DateTime?>(null);

  // Child side
  final RxBool isLinkedToParent = false.obs;
  final RxString parentName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock data: 2 anak sudah terhubung
    linkedChildren.value = [
      LinkedChild(
        id: 'child_1',
        name: 'Budi Santoso',
        email: 'budi@demo.com',
        isOnline: true,
        alertsToday: 2,
        linkedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      LinkedChild(
        id: 'child_2',
        name: 'Siti Nurhaliza',
        email: 'siti@demo.com',
        isOnline: false,
        alertsToday: 0,
        linkedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  // Generate invitation code
  void generateCode() {
    final random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += random.nextInt(10).toString();
    }

    generatedCode.value = code;
    isCodeActive.value = true;
    codeExpiresAt.value = DateTime.now().add(const Duration(minutes: 10));

    // Auto-expire after 10 minutes
    Future.delayed(const Duration(minutes: 10), () {
      if (generatedCode.value == code) {
        isCodeActive.value = false;
      }
    });
  }

  // Verify code (child side)
  Future<bool> verifyCode(String code) async {
    // Mock: simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Demo logic: accept any 6-digit code
    if (code.length == 6 && code == generatedCode.value && isCodeActive.value) {
      isLinkedToParent.value = true;
      parentName.value = 'Demo Parent';
      return true;
    }
    return false;
  }

  // Disconnect child
  void disconnectChild(String childId) {
    linkedChildren.removeWhere((child) => child.id == childId);
  }

  // Format code for display (XXX-XXX)
  String formatCode(String code) {
    if (code.length == 6) {
      return '${code.substring(0, 3)}-${code.substring(3, 6)}';
    }
    return code;
  }
}
