import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/notifications/notification_service.dart';
import '../../widgets/feature_item.dart';
import '../../widgets/threat_alert_overlay.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage>
    with TickerProviderStateMixin {
  bool isMonitoring = false;
  bool showAlert = false;
  String currentThreatLevel = 'safe';
  String lastDetection = '';
  int detectionCount = 0;
  late AnimationController _pulseController;
  late AnimationController _alertController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _alertAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _alertController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _alertAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _alertController, curve: Curves.elasticOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _alertController.dispose();
    super.dispose();
  }

  void _toggleMonitoring() {
    setState(() {
      isMonitoring = !isMonitoring;
      if (isMonitoring) {
        NotificationService().showMonitoringStatusNotification(isActive: true);
        Future.delayed(const Duration(seconds: 3), () {
          if (isMonitoring) _simulateDetection();
        });
      } else {
        NotificationService().showMonitoringStatusNotification(isActive: false);
        currentThreatLevel = 'safe';
      }
    });
  }

  void _simulateDetection() {
    if (!isMonitoring) return;

    final detectionTypes = [
      {'type': 'low', 'app': 'YouTube', 'content': 'Konten dewasa ringan'},
      {'type': 'medium', 'app': 'Browser', 'content': 'Situs tidak aman'},
      {'type': 'high', 'app': 'Instagram', 'content': 'Konten berbahaya'},
    ];

    final random = detectionTypes[detectionCount % detectionTypes.length];
    detectionCount++;

    setState(() {
      currentThreatLevel = random['type'] as String;
      lastDetection = '${random['app']} - ${random['content']}';
    });

    _showThreatNotification(
      random['type'] as String,
      random['app'] as String,
      random['content'] as String,
    );

    if (isMonitoring) {
      Future.delayed(const Duration(seconds: 5), _simulateDetection);
    }
  }

  void _showThreatNotification(String level, String app, String content) {
    if (level != 'safe') {
      setState(() {
        showAlert = true;
      });
      _alertController.forward();
    }

    NotificationService().showThreatNotification(
      threatLevel: level,
      appName: app,
      contentType: content,
    );
  }

  Color _getThreatColor() {
    switch (currentThreatLevel) {
      case 'low':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFEA580C);
      case 'high':
        return const Color(0xFFDC2626);
      case 'critical':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF10B981);
    }
  }

  String _getThreatText() {
    switch (currentThreatLevel) {
      case 'low':
        return 'Risiko Rendah';
      case 'medium':
        return 'Risiko Sedang';
      case 'high':
        return 'Risiko Tinggi';
      case 'critical':
        return 'BAHAYA KRITIS';
      default:
        return 'Aman';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Deteksi Real-time',
          style: GoogleFonts.inter(
            color: const Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoring aplikasi berisiko secara otomatis',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMonitoring
                            ? _getThreatColor()
                            : const Color(0xFFE5E7EB),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) => Transform.scale(
                                scale: isMonitoring ? _pulseAnimation.value : 1.0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: isMonitoring
                                        ? _getThreatColor()
                                        : const Color(0xFF9CA3AF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isMonitoring ? 'Monitoring aktif' : 'Monitoring tidak aktif',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF1F2937),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isMonitoring && currentThreatLevel != 'safe')
                                    Text(
                                      'Status: ${_getThreatText()}',
                                      style: GoogleFonts.inter(
                                        color: _getThreatColor(),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isMonitoring
                              ? 'Sistem sedang memantau layar dan menganalisis konten secara real-time'
                              : 'Tekan tombol di bawah untuk monitoring aplikasi',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isMonitoring && lastDetection.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getThreatColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getThreatColor().withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deteksi Terakhir:',
                                  style: GoogleFonts.inter(
                                    color: _getThreatColor(),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lastDetection,
                                  style: GoogleFonts.inter(
                                    color: _getThreatColor(),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: isSmallScreen ? 80 : 100,
                          height: isSmallScreen ? 80 : 100,
                          decoration: BoxDecoration(
                            color: isMonitoring
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isMonitoring
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF3B82F6))
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _toggleMonitoring,
                              borderRadius: BorderRadius.circular(50),
                              child: Center(
                                child: Icon(
                                  isMonitoring ? Icons.stop : Icons.play_arrow,
                                  color: Colors.white,
                                  size: isSmallScreen ? 35 : 45,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Text(
                          isMonitoring ? 'Stop Monitoring' : 'Mulai Deteksi',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1F2937),
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 32 : 40),
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: const [
                        FeatureItem(
                          icon: Icons.security,
                          title: 'AI Detection',
                          description:
                              'Menggunakan ai untuk mendeteksi\nkonten berisiko secara real-time',
                        ),
                        SizedBox(height: 16),
                        FeatureItem(
                          icon: Icons.notifications_active,
                          title: 'Smart Alert',
                          description:
                              'Notifikasi cerdas berdasarkan\ntingkat risiko konten',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showAlert)
            ThreatAlertOverlay(
              alertAnimation: _alertAnimation,
              pulseController: _pulseController,
              currentThreatLevel: currentThreatLevel,
              lastDetection: lastDetection,
              onClose: () {
                _alertController.reverse().then((_) {
                  setState(() => showAlert = false);
                });
              },
            ),
        ],
      ),
    );
  }
}
