import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen untuk Permission Request - Accessibility, Screen Capture, Overlay
class PermissionRequestScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const PermissionRequestScreen({super.key, required this.onComplete});

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  int _currentStep = 0;
  bool _accessibilityGranted = false;
  bool _screenCaptureGranted = false;
  bool _overlayGranted = false;

  final List<Map<String, dynamic>> _permissions = [
    {
      'title': 'Accessibility Service',
      'description':
          'Diperlukan untuk memantau aplikasi yang sedang aktif dan mendeteksi konten secara real-time.',
      'icon': Icons.accessibility_new_rounded,
      'color': const Color(0xFF3B82F6),
      'granted': false,
    },
    {
      'title': 'Screen Capture',
      'description':
          'Digunakan untuk mengambil screenshot konten yang perlu dianalisis oleh AI.',
      'icon': Icons.screenshot_rounded,
      'color': const Color(0xFF8B5CF6),
      'granted': false,
    },
    {
      'title': 'Overlay Permission',
      'description':
          'Memungkinkan popup intervensi CBT muncul di atas aplikasi lain.',
      'icon': Icons.layers_rounded,
      'color': const Color(0xFF10B981),
      'granted': false,
    },
  ];

  void _requestPermission(int index) async {
    // TODO: Implement actual permission request
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _permissions[index]['granted'] = true;
      switch (index) {
        case 0:
          _accessibilityGranted = true;
          break;
        case 1:
          _screenCaptureGranted = true;
          break;
        case 2:
          _overlayGranted = true;
          break;
      }
    });

    if (_currentStep < 2) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _currentStep++;
        });
      });
    } else if (_allPermissionsGranted()) {
      _showCompletionDialog();
    }
  }

  bool _allPermissionsGranted() {
    return _accessibilityGranted && _screenCaptureGranted && _overlayGranted;
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Semua Izin Diberikan!',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Paradise Guardian siap melindungi aktivitas digital kamu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onComplete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Mulai Sekarang',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Izin Diperlukan',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paradise Guardian membutuhkan beberapa izin untuk bekerja optimal',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: _permissions[index]['granted']
                            ? const Color(0xFF10B981)
                            : index == _currentStep
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 32),

            // Permission Cards
            Expanded(
              child: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: PageController(initialPage: _currentStep),
                itemCount: 3,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemBuilder: (context, index) {
                  final permission = _permissions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: (permission['color'] as Color)
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  permission['icon'] as IconData,
                                  color: permission['color'] as Color,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                permission['title'] as String,
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                permission['description'] as String,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: const Color(0xFF64748B),
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (permission['granted'] as bool)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF10B981),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Izin Diberikan',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _requestPermission(index),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          permission['color'] as Color,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Berikan Izin',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Step Indicator
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Langkah ${_currentStep + 1} dari 3',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
