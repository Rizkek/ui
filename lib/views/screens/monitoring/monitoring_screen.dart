import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/monitoring/auto_screenshot_service.dart';
import '../../../services/monitoring/app_detection_service.dart';
import '../../../controllers/monitoring_approval_controller.dart';
import '../../widgets/waiting_for_parent_approval_dialog.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  late AutoScreenshotService _screenshotService;
  final AppDetectionService _appDetectionService = AppDetectionService();
  late MonitoringApprovalController _approvalController;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AutoScreenshotService>()) {
      Get.put(AutoScreenshotService());
    }
    _screenshotService = Get.find<AutoScreenshotService>();

    // Initialize approval controller
    if (!Get.isRegistered<MonitoringApprovalController>()) {
      Get.put(MonitoringApprovalController());
    }
    _approvalController = Get.find<MonitoringApprovalController>();

    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.photos.isDenied) {
      await Permission.photos.request();
    }
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (await Permission.systemAlertWindow.isDenied) {
        if (mounted) _showOverlayPermissionDialog();
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () async {
      bool hasPermission = await _appDetectionService.hasPermission();
      if (!hasPermission && mounted) _showUsageStatsPermissionDialog();
    });
  }

  void _showOverlayPermissionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.security, color: Color(0xFF6366F1)),
            const SizedBox(width: 12),
            Text(
              'Izin Overlay',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Aplikasi memerlukan izin "Display over other apps" untuk menampilkan alert NSFW.',
          style: GoogleFonts.raleway(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Nanti')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Permission.systemAlertWindow.request();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Aktifkan'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showUsageStatsPermissionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.apps, color: Color(0xFF6366F1)),
            const SizedBox(width: 12),
            Text(
              'Izin Usage Access',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Aplikasi memerlukan izin "Usage Access" untuk mendeteksi aplikasi yang sedang dibuka.',
          style: GoogleFonts.raleway(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Nanti')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _appDetectionService.requestPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Buka Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A90E2), Color(0xFF8E2DE2)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.shield_moon,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paradise Monitor',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Real-time Protection',
                            style: GoogleFonts.raleway(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Status Card with Glassmorphism feel (simulated)
                          _buildStatusCard(),
                          const SizedBox(height: 24),

                          // Stats Grid
                          _buildStatsGrid(),
                          const SizedBox(height: 24),

                          // Control Button
                          _buildControlButton(),
                          const SizedBox(height: 32),

                          // Screenshot Gallery
                          _buildScreenshotGallery(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Obx(() {
      final isRecording = _screenshotService.isRecording.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isRecording
                  ? Colors.red.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isRecording
                ? Colors.red.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRecording
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRecording ? Icons.security : Icons.security_update_warning,
                size: 40,
                color: isRecording
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isRecording ? 'PROTEKSI AKTIF' : 'PROTEKSI NON-AKTIF',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isRecording
                  ? 'Sistem sedang memantau aktivitas layar secara real-time.'
                  : 'Aktifkan untuk mulai memantau aktivitas anak.',
              textAlign: TextAlign.center,
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatsGrid() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.camera_alt_outlined,
              label: 'Screenshots',
              value: '${_screenshotService.screenshotCount.value}',
              color: const Color(0xFF8B5CF6),
              bgColor: const Color(0xFFF5F3FF),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.grid_view_rounded,
              label: 'Aplikasi Aktif',
              value: _screenshotService.currentApp.value.isEmpty
                  ? 'None'
                  : _screenshotService.currentApp.value.length > 8
                  ? '${_screenshotService.currentApp.value.substring(0, 8)}..'
                  : _screenshotService.currentApp.value,
              color: const Color(0xFF10B981),
              bgColor: const Color(0xFFECFDF5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.raleway(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton() {
    return Obx(() {
      final isRecording = _screenshotService.isRecording.value;
      return GestureDetector(
        onTap: () async {
          if (isRecording) {
            // Cek apakah parental mode enabled
            final parentalModeEnabled = await _approvalController
                .isParentalModeEnabled();

            if (parentalModeEnabled) {
              // Jika parental mode aktif, butuh approval dari orang tua
              await _handleStopWithApproval();
            } else {
              // Jika tidak ada parental mode, langsung stop
              _screenshotService.stopAutoScreenshot();
              Get.snackbar(
                'ℹ️ Monitoring Dihentikan',
                'Monitoring telah dinonaktifkan',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            }
          } else {
            // Langsung set recording tanpa permission request
            // Permission sudah diminta di toggle "Monitoring dari Orang Tua"
            _screenshotService.isRecording.value = true;
            Get.snackbar(
              '✅ Monitoring Aktif',
              'Monitoring telah diaktifkan. Screenshot akan diambil setiap 5 detik.',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isRecording
                  ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                  : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isRecording
                    ? const Color(0xFFEF4444).withOpacity(0.4)
                    : const Color(0xFF3B82F6).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRecording
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isRecording ? 'HENTIKAN MONITORING' : 'MULAI MONITORING',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Handle stop monitoring dengan approval flow (2FA PIN System)
  Future<void> _handleStopWithApproval() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        '❌ Error',
        'User tidak terautentikasi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // TODO: Get parent user ID dari Firestore (linked account)
    // Untuk sekarang, kita gunakan user ID yang sama (demo purposes)
    final parentUserId = user.uid;
    final childUserId = user.uid;
    final childName = user.displayName ?? 'Anak';

    // Create request
    final requestId = await _approvalController.createStopMonitoringRequest(
      childUserId: childUserId,
      childName: childName,
      parentUserId: parentUserId,
    );

    if (requestId == null) {
      Get.snackbar(
        '❌ Error',
        'Gagal membuat permintaan approval',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show waiting dialog
    if (!mounted) return;

    await WaitingForParentApprovalDialog.show(
      context: context,
      childName: childName,
      onCancel: () {
        _approvalController.cancelRequest(requestId);
        Get.back();
      },
    );

    // Listen ke status changes
    _approvalController.currentRequest.listen((request) {
      if (request != null && !request.isPending) {
        // Close dialog
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        // Handle status
        if (request.status == 'approved') {
          _screenshotService.stopAutoScreenshot();
          Get.snackbar(
            '✅ Disetujui',
            'Monitoring telah dihentikan oleh orang tua',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else if (request.status == 'rejected') {
          Get.snackbar(
            '❌ Ditolak',
            'Permintaan stop monitoring ditolak oleh orang tua',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else if (request.status == 'timeout') {
          Get.snackbar(
            '⏱️ Timeout',
            'Permintaan melebihi batas waktu (5 menit)',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }

        _approvalController.clearCurrentRequest();
      }
    });
  }

  Widget _buildScreenshotGallery() {
    return Obx(() {
      if (_screenshotService.screenshots.isEmpty) {
        return _buildEmptyGallery();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Tangkapan Layar',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_screenshotService.screenshots.length} Item',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: _screenshotService.screenshots.length,
            reverse: true,
            itemBuilder: (context, index) {
              final reversedIndex =
                  _screenshotService.screenshots.length - 1 - index;
              final screenshot = _screenshotService.screenshots[reversedIndex];
              final imageBytes = screenshot['image_bytes'];

              return GestureDetector(
                onTap: () => _showFullscreenImage(screenshot),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.memory(imageBytes, fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              screenshot['app_name'],
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF1E293B),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              screenshot['timestamp'].toString().substring(
                                11,
                                19,
                              ),
                              style: GoogleFonts.raleway(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildEmptyGallery() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tangkapan layar akan muncul di sini saat monitoring aktif.',
            style: GoogleFonts.raleway(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFullscreenImage(Map<String, dynamic> screenshot) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(0),
        backgroundColor: Colors.black.withOpacity(0.9),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(child: Image.memory(screenshot['image_bytes'])),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
