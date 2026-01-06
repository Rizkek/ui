import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/monitoring_request.dart';

/// Service untuk handle monitoring approval requests via Firestore
class MonitoringRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _requestsCollection =>
      _firestore.collection('monitoring_requests');

  /// Create new monitoring request (dari device anak)
  Future<String> createStopMonitoringRequest({
    required String childUserId,
    required String childName,
    required String parentUserId,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 5)); // 5 menit timeout

      final request = MonitoringRequest(
        requestId: '', // Will be set by Firestore
        childUserId: childUserId,
        childName: childName,
        parentUserId: parentUserId,
        requestType: 'stop_monitoring',
        status: 'pending',
        createdAt: now,
        expiresAt: expiresAt,
        deviceInfo: deviceInfo,
      );

      final docRef = await _requestsCollection.add(request.toMap());

      return docRef.id;
    } catch (e) {
      print('Error creating monitoring request: $e');
      rethrow;
    }
  }

  /// Listen to request status changes (untuk device anak)
  Stream<MonitoringRequest?> listenToRequest(String requestId) {
    return _requestsCollection.doc(requestId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return MonitoringRequest.fromMap(
        snapshot.data() as Map<String, dynamic>,
        snapshot.id,
      );
    });
  }

  /// Get pending requests untuk parent (untuk device ortu)
  Stream<List<MonitoringRequest>> getPendingRequestsForParent(
    String parentUserId,
  ) {
    return _requestsCollection
        .where('parentUserId', isEqualTo: parentUserId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => MonitoringRequest.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .where((req) => !req.isExpired) // Filter expired
              .toList();
        });
  }

  /// Approve request (dari device ortu)
  Future<void> approveRequest(String requestId) async {
    try {
      await _requestsCollection.doc(requestId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error approving request: $e');
      rethrow;
    }
  }

  /// Reject request (dari device ortu)
  Future<void> rejectRequest(String requestId) async {
    try {
      await _requestsCollection.doc(requestId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error rejecting request: $e');
      rethrow;
    }
  }

  /// Cancel request (dari device anak)
  Future<void> cancelRequest(String requestId) async {
    try {
      await _requestsCollection.doc(requestId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error cancelling request: $e');
      rethrow;
    }
  }

  /// Mark request as timeout
  Future<void> markAsTimeout(String requestId) async {
    try {
      await _requestsCollection.doc(requestId).update({
        'status': 'timeout',
        'timeoutAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking as timeout: $e');
      rethrow;
    }
  }

  /// Get device info
  Map<String, dynamic> getDeviceInfo() {
    // TODO: Implement proper device info collection
    return {
      'platform': 'Android',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
