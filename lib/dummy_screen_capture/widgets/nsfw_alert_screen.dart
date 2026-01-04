import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// NsfwAlertScreen - Full-screen notification untuk konten NSFW
/// 
/// Ditampilkan secara immersive (tanpa status bar/nav bar) ketika API
/// mengembalikan nsfw_level 1, 2, atau 3.
/// 
/// LEVEL:
/// - 0: Aman (tidak ada notifikasi)
/// - 1: Low NSFW (peringatan rendah, bisa abaikan)
/// - 2: Medium NSFW (peringatan sedang, disarankan tutup)
/// - 3: High NSFW (peringatan tinggi, harus tutup)
class NsfwAlertScreen extends StatefulWidget {
  final int nsfwLevel;
  final String appName;

  const NsfwAlertScreen({
    super.key,
    required this.nsfwLevel,
    required this.appName,
  });

  @override
  State<NsfwAlertScreen> createState() => _NsfwAlertScreenState();
}

class _NsfwAlertScreenState extends State<NsfwAlertScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Config untuk tiap level
  late _AlertConfig _config;

  @override
  void initState() {
    super.initState();

    // Set immersive full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Setup animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Config berdasarkan level
    _config = _getConfigForLevel(widget.nsfwLevel);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  _AlertConfig _getConfigForLevel(int level) {
    switch (level) {
      case 1:
        return _AlertConfig(
          level: 1,
          levelName: 'LOW',
          color: const Color(0xFFF59E0B), // Amber/Yellow
          title: 'Peringatan Konten Rendah',
          message:
              'Terdeteksi konten yang berpotensi tidak pantas pada aplikasi "${widget.appName}".\n\n'
              'Level risiko: RENDAH\n\n'
              'Anda dapat memilih untuk mengabaikan atau menutup aplikasi.',
          icon: Icons.info_rounded,
          showIgnoreButton: true,
        );
      case 2:
        return _AlertConfig(
          level: 2,
          levelName: 'MEDIUM',
          color: const Color(0xFFEA580C), // Orange
          title: 'Peringatan Konten Sedang',
          message:
              'Terdeteksi konten tidak pantas pada aplikasi "${widget.appName}".\n\n'
              'Level risiko: SEDANG\n\n'
              'Disarankan untuk segera menutup aplikasi.',
          icon: Icons.warning_amber_rounded,
          showIgnoreButton: false,
        );
      case 3:
        return _AlertConfig(
          level: 3,
          levelName: 'HIGH',
          color: const Color(0xFFDC2626), // Red
          title: 'Peringatan Konten Tinggi',
          message:
              'Terdeteksi konten sangat tidak pantas pada aplikasi "${widget.appName}".\n\n'
              'Level risiko: TINGGI\n\n'
              'Harap segera tutup aplikasi!',
          icon: Icons.shield_rounded,
          showIgnoreButton: false,
        );
      default:
        return _AlertConfig(
          level: 0,
          levelName: 'SAFE',
          color: const Color(0xFF10B981),
          title: 'Konten Aman',
          message: 'Tidak ada konten tidak pantas terdeteksi.',
          icon: Icons.check_circle_rounded,
          showIgnoreButton: true,
        );
    }
  }

  void _closeAlert() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back button on low level, force on medium/high
      onWillPop: () async => _config.showIgnoreButton,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.95),
        body: Stack(
          children: [
            // Background gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    _config.color.withOpacity(0.2),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated icon
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _config.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _config.color,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _config.color.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _config.icon,
                            color: _config.color,
                            size: 60,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Level badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _config.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _config.color,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'LEVEL ${_config.level}: ${_config.levelName}',
                          style: GoogleFonts.inter(
                            color: _config.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        _config.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Message
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          _config.message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Buttons
                      if (_config.showIgnoreButton)
                        // LOW level: Show two buttons (Abaikan & Tutup)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _closeAlert,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Abaikan',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _closeAlert();
                                  // TODO: Implement actual app closing logic
                                  // Could use platform channel to close detected app
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _config.color,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Tutup App',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        // MEDIUM/HIGH level: Only close button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _closeAlert();
                              // TODO: Implement actual app closing logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _config.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.exit_to_app_rounded),
                            label: Text(
                              'Tutup Aplikasi',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Close button (top right) - only for LOW level
            if (_config.showIgnoreButton)
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: _closeAlert,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Config class untuk tiap level
class _AlertConfig {
  final int level;
  final String levelName;
  final Color color;
  final String title;
  final String message;
  final IconData icon;
  final bool showIgnoreButton;

  _AlertConfig({
    required this.level,
    required this.levelName,
    required this.color,
    required this.title,
    required this.message,
    required this.icon,
    required this.showIgnoreButton,
  });
}
