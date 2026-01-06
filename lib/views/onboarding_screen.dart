import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/Onboarding1.png",
      "title": "Lindungi Keluarga\nDengan Cerdas",
      "desc":
          "Deteksi otomatis konten yang tidak diinginkan dengan teknologi AI yang canggih.",
    },
    {
      "image": "assets/images/Onboarding2.png",
      "title": "Notifikasi Real-time\nKe Ponsel Anda",
      "desc":
          "Dapatkan pemberitahuan langsung saat terdeteksi aktivitas yang mencurigakan.",
    },
    {
      "image": "assets/images/Onboarding3.png",
      "title": "Aman & Nyaman\nBersama Paradise",
      "desc":
          "Ciptakan lingkungan digital yang sehat untuk tumbuh kembang buah hati.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // WillPopScope is deprecated in newer Flutter, but often still works.
    // Using PopScope is better if available, but staying consistent with existing code style.
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              children: [
                // Image Section
                Expanded(
                  flex: 1, // Increased prominence (was 3:2, now 1:1)
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (int page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return _buildImagePage(_onboardingData[index]["image"]!);
                    },
                  ),
                ),

                // Content Section
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPageIndicators(),
                            const SizedBox(height: 24),
                            Text(
                              _onboardingData[currentPage]["title"]!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF1E293B),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _onboardingData[currentPage]["desc"]!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.raleway(
                                color: const Color(0xFF64748B),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Skip Button
                            if (currentPage < 2)
                              TextButton(
                                onPressed: _skipOnboarding,
                                child: Text(
                                  'Lewati',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 80),
                            // Next/Start Button
                            ElevatedButton(
                              onPressed: currentPage == 2
                                  ? _getStarted
                                  : _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor: const Color(
                                  0xFF3B82F6,
                                ).withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currentPage == 2 ? 'Mulai' : 'Lanjut',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (currentPage != 2)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePage(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image isn't found
          return Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_rounded,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  "Image not found",
                  style: GoogleFonts.raleway(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _getStarted() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
