// Model untuk Monitoring Request (2FA System)
class MonitoringRequest {
  final String requestId;
  final String childUserId;
  final String childName;
  final String parentUserId;
  final String requestType; // 'stop_monitoring'
  final String status; // 'pending', 'approved', 'rejected', 'timeout'
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime expiresAt;
  final Map<String, dynamic>? deviceInfo;

  MonitoringRequest({
    required this.requestId,
    required this.childUserId,
    required this.childName,
    required this.parentUserId,
    required this.requestType,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.rejectedAt,
    required this.expiresAt,
    this.deviceInfo,
  });

  // From Firestore
  factory MonitoringRequest.fromMap(Map<String, dynamic> map, String id) {
    return MonitoringRequest(
      requestId: id,
      childUserId: map['childUserId'] ?? '',
      childName: map['childName'] ?? '',
      parentUserId: map['parentUserId'] ?? '',
      requestType: map['requestType'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as dynamic).toDate(),
      approvedAt: map['approvedAt'] != null
          ? (map['approvedAt'] as dynamic).toDate()
          : null,
      rejectedAt: map['rejectedAt'] != null
          ? (map['rejectedAt'] as dynamic).toDate()
          : null,
      expiresAt: (map['expiresAt'] as dynamic).toDate(),
      deviceInfo: map['deviceInfo'],
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'childUserId': childUserId,
      'childName': childName,
      'parentUserId': parentUserId,
      'requestType': requestType,
      'status': status,
      'createdAt': createdAt,
      'approvedAt': approvedAt,
      'rejectedAt': rejectedAt,
      'expiresAt': expiresAt,
      'deviceInfo': deviceInfo,
    };
  }

  // Check if expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  // Check if still pending
  bool get isPending {
    return status == 'pending' && !isExpired;
  }
}
