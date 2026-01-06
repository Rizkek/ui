import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controllers/monitoring_approval_controller.dart';
import '../../widgets/pin_approval_dialog.dart';

/// Widget untuk menampilkan pending monitoring requests (Device ORTU)
class PendingRequestsPanel extends StatefulWidget {
  const PendingRequestsPanel({super.key});

  @override
  State<PendingRequestsPanel> createState() => _PendingRequestsPanelState();
}

class _PendingRequestsPanelState extends State<PendingRequestsPanel> {
  late MonitoringApprovalController _approvalController;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    if (!Get.isRegistered<MonitoringApprovalController>()) {
      Get.put(MonitoringApprovalController());
    }
    _approvalController = Get.find<MonitoringApprovalController>();

    // Start listening to pending requests
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _approvalController.listenToPendingRequests(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pendingRequests = _approvalController.pendingRequests;

      if (pendingRequests.isEmpty) {
        return _buildEmptyState();
      }

      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notification_important,
                    color: const Color(0xFFF59E0B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permintaan Menunggu',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${pendingRequests.length} permintaan perlu approval',
                        style: GoogleFonts.raleway(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${pendingRequests.length}',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            ...pendingRequests.map((request) {
              return _buildRequestItem(request);
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 48,
              color: const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Permintaan',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua permintaan telah diproses',
            style: GoogleFonts.raleway(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestItem(request) {
    final isExpired = request.isExpired;
    final timeRemaining = request.expiresAt.difference(DateTime.now());
    final minutesRemaining = timeRemaining.inMinutes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isExpired ? const Color(0xFFFEF2F2) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpired ? const Color(0xFFFCA5A5) : const Color(0xFFFCD34D),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.childName,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Meminta stop monitoring',
                      style: GoogleFonts.raleway(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${minutesRemaining}m',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isExpired
                      ? null
                      : () async {
                          await _approvalController.rejectRequest(
                            request.requestId,
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: isExpired
                          ? Colors.grey.shade300
                          : const Color(0xFFE2E8F0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Tolak',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isExpired ? Colors.grey : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isExpired
                      ? null
                      : () {
                          _showPinDialog(request);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpired
                        ? Colors.grey.shade300
                        : const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Approve',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isExpired ? Colors.grey : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPinDialog(request) {
    PinApprovalDialog.show(
      context: context,
      requestId: request.requestId,
      childName: request.childName,
      onApproved: () {
        Get.back();
      },
      onRejected: () {
        _approvalController.rejectRequest(request.requestId);
        Get.back();
      },
      onPinSubmit: (pin) async {
        final success = await _approvalController.approveRequest(
          request.requestId,
          pin,
        );

        if (success) {
          Get.back();
        }
      },
    );
  }
}
