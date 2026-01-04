import 'package:flutter/foundation.dart';
import '../../models/risk_detection.dart';

/// Service untuk deteksi content triggers
class ContentTriggerService {
  // Database content triggers (ini bisa dari API/database)
  static final List<ContentTrigger> _triggers = [
    // HIGH RISK TRIGGERS
    ContentTrigger(
      keyword: 'porn',
      riskLevel: RiskLevel.high,
      category: 'Konten Dewasa',
    ),
    ContentTrigger(
      keyword: 'xxx',
      riskLevel: RiskLevel.high,
      category: 'Konten Dewasa',
    ),
    ContentTrigger(
      keyword: 'sex',
      riskLevel: RiskLevel.high,
      category: 'Konten Dewasa',
    ),
    ContentTrigger(
      keyword: 'adult',
      riskLevel: RiskLevel.high,
      category: 'Konten Dewasa',
    ),
    ContentTrigger(
      keyword: 'violence',
      riskLevel: RiskLevel.high,
      category: 'Kekerasan',
    ),
    ContentTrigger(
      keyword: 'gore',
      riskLevel: RiskLevel.high,
      category: 'Kekerasan',
    ),
    ContentTrigger(
      keyword: 'suicide',
      riskLevel: RiskLevel.high,
      category: 'Self-Harm',
    ),
    ContentTrigger(
      keyword: 'drugs',
      riskLevel: RiskLevel.high,
      category: 'Narkoba',
    ),

    // MEDIUM RISK TRIGGERS
    ContentTrigger(
      keyword: 'dating',
      riskLevel: RiskLevel.medium,
      category: 'Konten Romantis',
    ),
    ContentTrigger(
      keyword: 'gambling',
      riskLevel: RiskLevel.medium,
      category: 'Perjudian',
    ),
    ContentTrigger(
      keyword: 'casino',
      riskLevel: RiskLevel.medium,
      category: 'Perjudian',
    ),
    ContentTrigger(
      keyword: 'bet',
      riskLevel: RiskLevel.medium,
      category: 'Perjudian',
    ),
    ContentTrigger(
      keyword: 'horror',
      riskLevel: RiskLevel.medium,
      category: 'Konten Menakutkan',
    ),
    ContentTrigger(
      keyword: 'weapon',
      riskLevel: RiskLevel.medium,
      category: 'Senjata',
    ),

    // LOW RISK TRIGGERS
    ContentTrigger(
      keyword: 'chat',
      riskLevel: RiskLevel.low,
      category: 'Komunikasi',
    ),
    ContentTrigger(
      keyword: 'stranger',
      riskLevel: RiskLevel.low,
      category: 'Interaksi Asing',
    ),
    ContentTrigger(
      keyword: 'meet',
      riskLevel: RiskLevel.low,
      category: 'Pertemuan',
    ),
  ];

  /// Deteksi konten berdasarkan text/URL
  static Future<RiskDetection?> detectContent({
    required String appName,
    required String packageName,
    String? textContent,
    String? url,
  }) async {
    try {
      // Gabungkan text dan URL untuk analisis
      final contentToAnalyze = '${textContent ?? ''} ${url ?? ''}'
          .toLowerCase();

      if (contentToAnalyze.trim().isEmpty) {
        return null;
      }

      // Cari triggers yang cocok
      final matchedTriggers = <ContentTrigger>[];
      for (final trigger in _triggers) {
        if (contentToAnalyze.contains(trigger.keyword.toLowerCase())) {
          matchedTriggers.add(trigger);
        }
      }

      if (matchedTriggers.isEmpty) {
        return null;
      }

      // Tentukan risk level tertinggi
      RiskLevel highestRisk = RiskLevel.low;
      for (final trigger in matchedTriggers) {
        if (trigger.riskLevel.index > highestRisk.index) {
          highestRisk = trigger.riskLevel;
        }
      }

      // Buat detection report
      final detection = RiskDetection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        appName: appName,
        packageName: packageName,
        riskLevel: highestRisk,
        detectedContent: _createContentSummary(matchedTriggers),
        detectedAt: DateTime.now(),
        isBlocked: highestRisk == RiskLevel.high, // Auto block high risk
        triggers: matchedTriggers.map((t) => t.keyword).toList(),
      );

      debugPrint('🚨 CONTENT DETECTED: ${detection.riskLevel.name} - $appName');
      debugPrint('   Triggers: ${detection.triggers.join(', ')}');

      return detection;
    } catch (e) {
      debugPrint('❌ Error detecting content: $e');
      return null;
    }
  }

  /// Analisis package name aplikasi untuk risiko
  static RiskLevel analyzePackageName(String packageName) {
    final lowerPackage = packageName.toLowerCase();

    // High risk packages
    final highRiskKeywords = [
      'porn',
      'xxx',
      'adult',
      'sex',
      'dating',
      'hookup',
      'gambling',
      'casino',
      'vpn',
      'torrent',
    ];

    // Medium risk packages
    final mediumRiskKeywords = [
      'chat',
      'anonymous',
      'secret',
      'private',
      'game',
      'social',
      'meet',
    ];

    for (final keyword in highRiskKeywords) {
      if (lowerPackage.contains(keyword)) {
        return RiskLevel.high;
      }
    }

    for (final keyword in mediumRiskKeywords) {
      if (lowerPackage.contains(keyword)) {
        return RiskLevel.medium;
      }
    }

    return RiskLevel.low;
  }

  /// Check apakah app dalam blacklist
  static bool isBlacklistedApp(String packageName) {
    final blacklist = [
      'com.pornhub',
      'com.xvideos',
      'com.redtube',
      'com.youporn',
      // Add more as needed
    ];

    return blacklist.any((pkg) => packageName.toLowerCase().contains(pkg));
  }

  /// Get semua triggers berdasarkan risk level
  static List<ContentTrigger> getTriggersByRiskLevel(RiskLevel level) {
    return _triggers.where((t) => t.riskLevel == level).toList();
  }

  /// Get semua triggers berdasarkan category
  static List<ContentTrigger> getTriggersByCategory(String category) {
    return _triggers.where((t) => t.category == category).toList();
  }

  /// Get semua categories
  static List<String> getAllCategories() {
    return _triggers.map((t) => t.category).toSet().toList();
  }

  /// Add custom trigger (untuk parent customization)
  static void addCustomTrigger(ContentTrigger trigger) {
    if (!_triggers.any((t) => t.keyword == trigger.keyword)) {
      _triggers.add(trigger);
      debugPrint('✅ Custom trigger added: ${trigger.keyword}');
    }
  }

  /// Remove trigger
  static void removeTrigger(String keyword) {
    _triggers.removeWhere((t) => t.keyword == keyword);
    debugPrint('🗑️ Trigger removed: $keyword');
  }

  /// Helper untuk create content summary
  static String _createContentSummary(List<ContentTrigger> triggers) {
    if (triggers.isEmpty) return 'Konten tidak pantas terdeteksi';

    final categories = triggers.map((t) => t.category).toSet();
    return 'Terdeteksi: ${categories.join(', ')}';
  }

  /// Analyze URL untuk risiko
  static Future<RiskDetection?> analyzeUrl(String url, String appName) async {
    return detectContent(appName: appName, packageName: 'browser', url: url);
  }

  /// Analyze text content
  static Future<RiskDetection?> analyzeText(
    String text,
    String appName,
    String packageName,
  ) async {
    return detectContent(
      appName: appName,
      packageName: packageName,
      textContent: text,
    );
  }

  /// Monitor mode - untuk continuous monitoring
  static Stream<RiskDetection?> monitorContent({
    required String appName,
    required String packageName,
    required Stream<String> contentStream,
  }) async* {
    await for (final content in contentStream) {
      final detection = await detectContent(
        appName: appName,
        packageName: packageName,
        textContent: content,
      );

      if (detection != null) {
        yield detection;
      }
    }
  }

  /// Get statistics
  static Map<String, int> getTriggerStatistics() {
    final stats = <String, int>{};

    for (final level in RiskLevel.values) {
      stats[level.name] = _triggers.where((t) => t.riskLevel == level).length;
    }

    return stats;
  }

  /// Export triggers untuk backup
  static List<Map<String, dynamic>> exportTriggers() {
    return _triggers.map((t) => t.toJson()).toList();
  }

  /// Import triggers dari backup
  static void importTriggers(List<Map<String, dynamic>> triggersJson) {
    _triggers.clear();
    _triggers.addAll(triggersJson.map((json) => ContentTrigger.fromJson(json)));
    debugPrint('✅ Imported ${_triggers.length} triggers');
  }

  /// Reset ke default triggers
  static void resetToDefault() {
    // This will reset when app restarts
    // Or you can implement a default list storage
    debugPrint('⚠️ Triggers will reset to default on app restart');
  }
}
