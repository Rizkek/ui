import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../widgets/cbt_intervention_popup.dart';
import '../chatbot/ai_chatbot_screen.dart';

/// Halaman Deteksi Real-time sesuai requirement
class DetectionRealtimePage extends StatefulWidget {
  const DetectionRealtimePage({super.key});

  @override
  State<DetectionRealtimePage> createState() => _DetectionRealtimePageState();
}

class _DetectionRealtimePageState extends State<DetectionRealtimePage>
    with TickerProviderStateMixin {
  bool _isMonitoring = false;
  bool _parentModeEnabled = false; // TODO: Load from storage/API
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadMonitoringStatus();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadMonitoringStatus() async {
    // TODO: Load from storage
    setState(() {
      _isMonitoring = false;
      _parentModeEnabled = false;
    });
  }

  void _toggleMonitoring() async {
    if (_isMonitoring && _parentModeEnabled) {
      // Parent mode ON, butuh PIN
      _showPINDialog();
      return;
    }

    setState(() {
      _isMonitoring = !_isMonitoring;
    });

    if (_isMonitoring) {
      _pulseController.repeat(reverse: true);
      // TODO: Start background service
      Get.snackbar(
        'Monitoring Aktif',
        'Sistem akan mendeteksi konten berisiko secara otomatis',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );

      // Demo: Show popup after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (_isMonitoring) {
          _showDemoDetection();
        }
      });
    } else {
      _pulseController.stop();
      // TODO: Stop background service
      Get.snackbar(
        'Monitoring Dihentikan',
        'Sistem deteksi tidak aktif',
        backgroundColor: const Color(0xFF6B7280),
        colorText: Colors.white,
        icon: const Icon(Icons.info, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _showPINDialog() {
    // TODO: Implement PIN dialog
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Masukkan PIN Orang Tua',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Monitoring dikunci oleh orang tua. Masukkan PIN untuk menonaktifkan.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'Masukkan PIN',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (pin) {
                // TODO: Verify PIN
                if (pin == '123456') {
                  Get.back();
                  setState(() {
                    _isMonitoring = false;
                    _pulseController.stop();
                  });
                  Get.snackbar(
                    'Berhasil',
                    'Monitoring dihentikan',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'PIN Salah',
                    'Coba lagi',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        ],
      ),
    );
  }

  void _showDemoDetection() {
    // Randomly select different risk levels
    final riskLevels = ['low', 'medium', 'high'];
    final selectedRisk = riskLevels[DateTime.now().second % riskLevels.length];

    final apps = {
      'low': {'name': 'YouTube', 'content': 'Konten Sensitif Ringan'},
      'medium': {'name': 'Instagram', 'content': 'Konten Sensitif Sedang'},
      'high': {'name': 'Browser', 'content': 'Konten Pornografi'},
    };

    final appInfo = apps[selectedRisk]!;

    CBTInterventionPopup.show(
      context: context,
      riskLevel: selectedRisk,
      appName: appInfo['name']!,
      contentType: appInfo['content'],
      onClose: () {
        print('Popup closed');
      },
      onCloseApp: () {
        print('Close app requested');
      },
      onOpenChatbot: () {
        Get.to(() => const AiChatbotScreen());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                'Deteksi Real-time',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aktifkan untuk monitoring otomatis',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 40),

              // Status Indicator
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isMonitoring ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isMonitoring
                              ? [
                                  const Color(0xFF10B981),
                                  const Color(0xFF059669),
                                ]
                              : [
                                  const Color(0xFFE5E7EB),
                                  const Color(0xFFD1D5DB),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isMonitoring
                                        ? const Color(0xFF10B981)
                                        : Colors.grey)
                                    .withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isMonitoring
                            ? Icons.shield_rounded
                            : Icons.shield_outlined,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Status Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isMonitoring
                          ? const Color(0xFF10B981)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isMonitoring ? 'Monitoring Aktif' : 'Tidak Aktif',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isMonitoring
                          ? const Color(0xFF10B981)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Toggle Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _toggleMonitoring,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isMonitoring
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _isMonitoring ? 'Hentikan Deteksi' : 'Mulai Deteksi',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (_parentModeEnabled && _isMonitoring) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Monitoring dikunci oleh orang tua',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Feature Cards
              Text(
                'Fitur Deteksi',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.psychology_rounded,
                title: 'AI Detection',
                description:
                    'Machine Learning untuk deteksi konten berisiko dengan akurasi tinggi',
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.notifications_active_rounded,
                title: 'Smart Alert',
                description:
                    'Popup intervensi CBT otomatis saat konten berisiko terdeteksi',
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.history_rounded,
                title: 'Activity Log',
                description:
                    'Catat semua aktivitas deteksi untuk analisis dan review',
                color: const Color(0xFF10B981),
              ),

              const SizedBox(height: 32),

              // Info Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3B82F6).withOpacity(0.1),
                      const Color(0xFF8B5CF6).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF3B82F6),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Cara Kerja Monitoring',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoStep(
                      '1',
                      'Sistem memantau aplikasi target secara real-time',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoStep(
                      '2',
                      'AI menganalisis konten visual yang muncul',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoStep(
                      '3',
                      'Deteksi otomatis dengan level Low/Medium/High',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoStep(
                      '4',
                      'Popup CBT intervention muncul saat risiko terdeteksi',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
