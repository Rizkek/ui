import 'package:flutter/material.dart';

/// Enum untuk level risiko deteksi konten
enum RiskLevel {
  low, // Risiko rendah - peringatan ringan
  medium, // Risiko sedang - peringatan + notifikasi ortu
  high, // Risiko tinggi - block otomatis + notifikasi urgent
}

/// Model untuk deteksi konten berisiko
class RiskDetection {
  final String id;
  final String appName;
  final String packageName;
  final RiskLevel riskLevel;
  final String detectedContent;
  final DateTime detectedAt;
  final bool isBlocked;
  final List<String> triggers; // Content triggers yang terdeteksi

  RiskDetection({
    required this.id,
    required this.appName,
    required this.packageName,
    required this.riskLevel,
    required this.detectedContent,
    required this.detectedAt,
    this.isBlocked = false,
    this.triggers = const [],
  });

  /// Mendapatkan warna berdasarkan risk level
  Color getRiskColor() {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.yellow.shade700;
      case RiskLevel.medium:
        return Colors.orange.shade600;
      case RiskLevel.high:
        return Colors.red.shade600;
    }
  }

  /// Mendapatkan icon berdasarkan risk level
  IconData getRiskIcon() {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.info_outline;
      case RiskLevel.medium:
        return Icons.warning_amber_rounded;
      case RiskLevel.high:
        return Icons.dangerous_outlined;
    }
  }

  /// Mendapatkan label risk level
  String getRiskLabel() {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Risiko Rendah';
      case RiskLevel.medium:
        return 'Risiko Sedang';
      case RiskLevel.high:
        return 'Risiko Tinggi';
    }
  }

  /// Mendapatkan deskripsi aksi berdasarkan risk level
  String getActionDescription() {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Peringatan diberikan kepada anak';
      case RiskLevel.medium:
        return 'Peringatan + Notifikasi ke orang tua';
      case RiskLevel.high:
        return 'Konten diblokir otomatis + Notifikasi urgent';
    }
  }

  /// Konversi dari Map (dari database/API)
  factory RiskDetection.fromJson(Map<String, dynamic> json) {
    return RiskDetection(
      id: json['id'] ?? '',
      appName: json['app_name'] ?? '',
      packageName: json['package_name'] ?? '',
      riskLevel: _parseRiskLevel(json['risk_level']),
      detectedContent: json['detected_content'] ?? '',
      detectedAt: json['detected_at'] != null
          ? DateTime.parse(json['detected_at'])
          : DateTime.now(),
      isBlocked: json['is_blocked'] ?? false,
      triggers: json['triggers'] != null
          ? List<String>.from(json['triggers'])
          : [],
    );
  }

  /// Konversi ke Map (untuk database/API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_name': appName,
      'package_name': packageName,
      'risk_level': riskLevel.name,
      'detected_content': detectedContent,
      'detected_at': detectedAt.toIso8601String(),
      'is_blocked': isBlocked,
      'triggers': triggers,
    };
  }

  /// Helper untuk parse risk level dari string
  static RiskLevel _parseRiskLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'low':
        return RiskLevel.low;
      case 'medium':
        return RiskLevel.medium;
      case 'high':
        return RiskLevel.high;
      default:
        return RiskLevel.low;
    }
  }

  /// Copy with method
  RiskDetection copyWith({
    String? id,
    String? appName,
    String? packageName,
    RiskLevel? riskLevel,
    String? detectedContent,
    DateTime? detectedAt,
    bool? isBlocked,
    List<String>? triggers,
  }) {
    return RiskDetection(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      riskLevel: riskLevel ?? this.riskLevel,
      detectedContent: detectedContent ?? this.detectedContent,
      detectedAt: detectedAt ?? this.detectedAt,
      isBlocked: isBlocked ?? this.isBlocked,
      triggers: triggers ?? this.triggers,
    );
  }
}

/// Content Triggers - kata kunci/pola yang memicu deteksi
class ContentTrigger {
  final String keyword;
  final RiskLevel riskLevel;
  final String category;

  ContentTrigger({
    required this.keyword,
    required this.riskLevel,
    required this.category,
  });

  factory ContentTrigger.fromJson(Map<String, dynamic> json) {
    return ContentTrigger(
      keyword: json['keyword'] ?? '',
      riskLevel: RiskDetection._parseRiskLevel(json['risk_level']),
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'risk_level': riskLevel.name,
      'category': category,
    };
  }
}

/// Psychoeducation content untuk edukasi anak dan ortu
class PsychoeducationContent {
  final String id;
  final String title;
  final String content;
  final RiskLevel relatedRiskLevel;
  final String imageUrl;
  final List<String> keyPoints;

  PsychoeducationContent({
    required this.id,
    required this.title,
    required this.content,
    required this.relatedRiskLevel,
    this.imageUrl = '',
    this.keyPoints = const [],
  });

  factory PsychoeducationContent.fromJson(Map<String, dynamic> json) {
    return PsychoeducationContent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      relatedRiskLevel: RiskDetection._parseRiskLevel(
        json['related_risk_level'],
      ),
      imageUrl: json['image_url'] ?? '',
      keyPoints: json['key_points'] != null
          ? List<String>.from(json['key_points'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'related_risk_level': relatedRiskLevel.name,
      'image_url': imageUrl,
      'key_points': keyPoints,
    };
  }
}
