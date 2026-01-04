import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThreatAlertOverlay extends StatelessWidget {
  final Animation<double> alertAnimation;
  final AnimationController pulseController;
  final String currentThreatLevel;
  final String lastDetection;
  final VoidCallback onClose;

  const ThreatAlertOverlay({
    super.key,
    required this.alertAnimation,
    required this.pulseController,
    required this.currentThreatLevel,
    required this.lastDetection,
    required this.onClose,
  });

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

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: FadeTransition(
        opacity: alertAnimation,
        child: SlideTransition(
          position: alertAnimation.drive(
            Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutBack)),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (context, child) => Transform.scale(
                        scale: 0.9 + (pulseController.value * 0.2),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getThreatColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Peringatan Deteksi: $lastDetection',
                        style: GoogleFonts.inter(
                          color: _getThreatColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Saran: Hindari konten ini dan laporkan bila berulang',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onClose,
                        icon: const Icon(Icons.visibility_off, size: 18),
                        label: const Text('Abaikan'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getThreatColor(),
                        ),
                        icon: const Icon(Icons.shield, size: 18),
                        label: const Text('Blokir Konten'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
