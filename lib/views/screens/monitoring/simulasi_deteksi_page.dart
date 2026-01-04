import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SimulasiDeteksiPage extends StatefulWidget {
  const SimulasiDeteksiPage({super.key});

  @override
  State<SimulasiDeteksiPage> createState() => _SimulasiDeteksiPageState();
}

class _SimulasiDeteksiPageState extends State<SimulasiDeteksiPage>
    with TickerProviderStateMixin {
  bool _isReady = true; // initial page like monitoring idle state

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  final List<_SimStep> _steps = const [
    _SimStep(
      assetPath: 'assets/images/low_nsfw.jpg',
      levelKey: 'low',
      title: 'Peringatan Konten Rendah',
      message: 'Terdeteksi konten berisiko rendah (Low NSFW).',
      color: Color(0xFFF59E0B), // yellow/amber for low
    ),
    _SimStep(
      assetPath: 'assets/images/medium_nsfw.jpg',
      levelKey: 'medium',
      title: 'Peringatan Konten Sedang',
      message: 'Terdeteksi konten berisiko sedang (Medium NSFW).',
      color: Color(0xFFEA580C),
    ),
    _SimStep(
      assetPath: 'assets/images/high_nsfw.jpg',
      levelKey: 'high',
      title: 'Peringatan Konten Tinggi',
      message: 'Terdeteksi konten berisiko tinggi (High NSFW).',
      color: Color(0xFFDC2626), // red for high
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startSimulasi() async {
    if (!_isReady) return;
    setState(() => _isReady = false);
    // Push a full-screen immersive route that hides app bar and bottom nav
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            _FullScreenSimulasiView(steps: _steps),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    if (!mounted) return;
    setState(() => _isReady = true);
  }

  Color _currentColor() => _isReady ? const Color(0xFF3B82F6) : const Color(0xFF10B981);
  String _currentText() => _isReady ? 'Aman' : 'Berjalan';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Simulasi Deteksi',
            style: GoogleFonts.inter(
              color: const Color(0xFF1F2937),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Text(
                    'Halaman simulasi sementara untuk menggantikan monitoring.',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: isSmall ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: isSmall ? 20 : 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _currentColor(), width: 2),
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: _pulseAnim,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _currentColor().withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.podcasts_rounded,
                                  color: _currentColor(),
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF6B7280),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _isReady ? 'Siap untuk simulasi' : 'Simulasi berjalan…',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF1F2937),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _currentColor().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Tingkat Risiko: ${_currentText()}',
                                      style: GoogleFonts.inter(
                                        color: _currentColor(),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isReady
                              ? 'Tekan tombol di bawah untuk memulai simulasi 3 tingkat NSFW.'
                              : 'Sedang menampilkan gambar simulasi secara penuh layar.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmall ? 24 : 32),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: isSmall ? 80 : 100,
                          height: isSmall ? 80 : 100,
                          decoration: BoxDecoration(
                            color: _isReady ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: _isReady ? _startSimulasi : null,
                              child: Icon(
                                _isReady ? Icons.play_arrow_rounded : Icons.hourglass_bottom_rounded,
                                color: Colors.white,
                                size: isSmall ? 38 : 44,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmall ? 12 : 16),
                        Text(
                          _isReady ? 'Mulai Simulasi' : 'Sedang Berjalan…',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
}

class _SimStep {
  final String assetPath;
  final String levelKey;
  final String title;
  final String message;
  final Color color;
  const _SimStep({
    required this.assetPath,
    required this.levelKey,
    required this.title,
    required this.message,
    required this.color,
  });
}

// A dedicated full-screen route to display images in immersive mode and show alerts sequentially.
class _FullScreenSimulasiView extends StatefulWidget {
  final List<_SimStep> steps;
  const _FullScreenSimulasiView({required this.steps});

  @override
  State<_FullScreenSimulasiView> createState() => _FullScreenSimulasiViewState();
}

class _FullScreenSimulasiViewState extends State<_FullScreenSimulasiView> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    // Enter immersive full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Ensure first alert pops after first frame so the image is visible already
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Tampilkan gambar dulu selama 2 detik, baru munculkan pop up pertama
      await Future.delayed(const Duration(seconds: 2));
      _showAlertFor(index);
    });
  }

  @override
  void dispose() {
    // Restore overlays
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _showAlertFor(int i) async {
    if (!mounted) return;
    final s = widget.steps[i];
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(1), // overlay putih di belakang pop up
      builder: (ctx) {
        final primary = s.color;
        final isLow = s.levelKey == 'low';
        final isMedium = s.levelKey == 'medium';
        final isHigh = s.levelKey == 'high';

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: primary, width: 2),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Container(
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: primary.withOpacity(0.25), width: 1)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: primary.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(
                    isHigh
                        ? Icons.shield_rounded
                        : isMedium
                            ? Icons.warning_amber_rounded
                            : Icons.info_rounded,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  s.levelKey.toUpperCase(),
                  style: GoogleFonts.inter(color: primary, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              Text(s.message, style: GoogleFonts.inter(height: 1.5, color: const Color(0xFF1F2937))),
            ],
          ),
          actions: [
            if (isLow)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primary),
                        foregroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Abaikan'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Tutup Aplikasi'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.exit_to_app_rounded),
                  label: const Text('Tutup Aplikasi'),
                ),
              ),
          ],
        );
      },
  );

    if (!mounted) return;
    if (index < widget.steps.length - 1) {
      // Ganti gambar dulu, lalu jeda 2 detik sebelum pop up berikutnya
      setState(() => index++);
      await Future.delayed(const Duration(seconds: 2));
      _showAlertFor(index);
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.steps[index];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              s.assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Gambar tidak ditemukan:\n${s.assetPath}', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white)),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
