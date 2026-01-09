/// Model untuk pengaturan mode orang tua
class ParentSettings {
  final String userId;
  final bool isParentModeEnabled;
  final String? pin; // PIN untuk disable deteksi
  final bool blockPopupEnabled; // Popup block otomatis
  final bool highRiskAutoBlock; // Auto block untuk high risk
  final bool mediumRiskNotify; // Notifikasi untuk medium risk
  final bool lowRiskWarning; // Warning untuk low risk
  final DateTime? lastUpdated;

  ParentSettings({
    required this.userId,
    this.isParentModeEnabled = false,
    this.pin,
    this.blockPopupEnabled = true, // Default aktif
    this.highRiskAutoBlock = true, // Default aktif
    this.mediumRiskNotify = true, // Default aktif
    this.lowRiskWarning = true, // Default aktif
    this.lastUpdated,
  });

  /// Validasi PIN (harus 6 digit)
  static bool isValidPin(String pin) {
    return pin.length == 6 && int.tryParse(pin) != null;
  }

  /// Verify PIN
  bool verifyPin(String inputPin) {
    return pin != null && pin == inputPin;
  }

  factory ParentSettings.fromJson(Map<String, dynamic> json) {
    return ParentSettings(
      userId: json['user_id'] ?? '',
      isParentModeEnabled: json['is_parent_mode_enabled'] ?? false,
      pin: json['pin'],
      blockPopupEnabled: json['block_popup_enabled'] ?? true,
      highRiskAutoBlock: json['high_risk_auto_block'] ?? true,
      mediumRiskNotify: json['medium_risk_notify'] ?? true,
      lowRiskWarning: json['low_risk_warning'] ?? true,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'is_parent_mode_enabled': isParentModeEnabled,
      'pin': pin,
      'block_popup_enabled': blockPopupEnabled,
      'high_risk_auto_block': highRiskAutoBlock,
      'medium_risk_notify': mediumRiskNotify,
      'low_risk_warning': lowRiskWarning,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  ParentSettings copyWith({
    String? userId,
    bool? isParentModeEnabled,
    String? pin,
    bool? blockPopupEnabled,
    bool? highRiskAutoBlock,
    bool? mediumRiskNotify,
    bool? lowRiskWarning,
    DateTime? lastUpdated,
  }) {
    return ParentSettings(
      userId: userId ?? this.userId,
      isParentModeEnabled: isParentModeEnabled ?? this.isParentModeEnabled,
      pin: pin ?? this.pin,
      blockPopupEnabled: blockPopupEnabled ?? this.blockPopupEnabled,
      highRiskAutoBlock: highRiskAutoBlock ?? this.highRiskAutoBlock,
      mediumRiskNotify: mediumRiskNotify ?? this.mediumRiskNotify,
      lowRiskWarning: lowRiskWarning ?? this.lowRiskWarning,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
