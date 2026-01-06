import 'package:get/get.dart';
import '../models/monitoring_request.dart';
import '../services/monitoring/monitoring_request_service.dart';
import '../services/storage/secure_storage_service.dart';

/// Controller untuk handle monitoring approval flow (2FA PIN System)
class MonitoringApprovalController extends GetxController {
  final MonitoringRequestService _requestService = MonitoringRequestService();

  // Observable untuk pending requests (untuk parent device)
  final RxList<MonitoringRequest> pendingRequests = <MonitoringRequest>[].obs;

  // Observable untuk current request (untuk child device yang sedang waiting)
  final Rx<MonitoringRequest?> currentRequest = Rx<MonitoringRequest?>(null);

  // Observable untuk loading state
  final RxBool isLoading = false.obs;

  /// Check apakah parental mode enabled
  Future<bool> isParentalModeEnabled() async {
    final parentalMode = await SecureStorageService.readData('parental_mode');
    return parentalMode == 'true';
  }

  /// Get parent PIN dari storage
  Future<String?> getParentPin() async {
    return await SecureStorageService.readData('parent_pin');
  }

  /// Create stop monitoring request dari child device
  Future<String?> createStopMonitoringRequest({
    required String childUserId,
    required String childName,
    required String parentUserId,
  }) async {
    try {
      isLoading.value = true;

      final requestId = await _requestService.createStopMonitoringRequest(
        childUserId: childUserId,
        childName: childName,
        parentUserId: parentUserId,
        deviceInfo: {
          'platform': 'android',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Listen ke request status changes
      listenToCurrentRequest(requestId);

      return requestId;
    } catch (e) {
      print('❌ Error creating request: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Listen ke status changes untuk child device yang sedang waiting
  void listenToCurrentRequest(String requestId) {
    _requestService
        .listenToRequest(requestId)
        .listen(
          (request) {
            if (request != null) {
              currentRequest.value = request;

              // Auto close jika approved, rejected, atau timeout
              if (!request.isPending) {
                // Handle completion
                if (request.status == 'approved') {
                  print('✅ Request approved!');
                } else if (request.status == 'rejected') {
                  print('❌ Request rejected');
                } else if (request.status == 'timeout') {
                  print('⏱️ Request timeout');
                }
              }
            }
          },
          onError: (error) {
            print('❌ Error listening to request: $error');
          },
        );
  }

  /// Listen ke pending requests untuk parent device
  void listenToPendingRequests(String parentUserId) {
    _requestService
        .getPendingRequestsForParent(parentUserId)
        .listen(
          (requests) {
            pendingRequests.value = requests;
            print('📋 Pending requests: ${requests.length}');
          },
          onError: (error) {
            print('❌ Error listening to pending requests: $error');
          },
        );
  }

  /// Approve request (dari parent device)
  Future<bool> approveRequest(String requestId, String enteredPin) async {
    try {
      isLoading.value = true;

      // Verify PIN
      final storedPin = await getParentPin();
      if (storedPin == null || storedPin != enteredPin) {
        Get.snackbar(
          '❌ PIN Salah',
          'PIN yang Anda masukkan tidak sesuai',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }

      // Approve request
      await _requestService.approveRequest(requestId);

      Get.snackbar(
        '✅ Disetujui',
        'Permintaan stop monitoring telah disetujui',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      return true;
    } catch (e) {
      print('❌ Error approving request: $e');
      Get.snackbar(
        '❌ Error',
        'Terjadi kesalahan saat menyetujui permintaan',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reject request (dari parent device)
  Future<void> rejectRequest(String requestId) async {
    try {
      isLoading.value = true;

      await _requestService.rejectRequest(requestId);

      Get.snackbar(
        'ℹ️ Ditolak',
        'Permintaan stop monitoring telah ditolak',
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );
    } catch (e) {
      print('❌ Error rejecting request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancel request (dari child device)
  Future<void> cancelRequest(String requestId) async {
    try {
      isLoading.value = true;

      await _requestService.cancelRequest(requestId);
      currentRequest.value = null;

      Get.snackbar(
        'ℹ️ Dibatalkan',
        'Permintaan telah dibatalkan',
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );
    } catch (e) {
      print('❌ Error canceling request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear current request
  void clearCurrentRequest() {
    currentRequest.value = null;
  }
}
