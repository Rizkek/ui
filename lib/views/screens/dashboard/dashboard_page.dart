import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/weekly_bar_chart.dart';
import '../../widgets/app_card.dart';
import '../../widgets/activity_card.dart';
import '../../widgets/skeleton_loader.dart';
import 'history_detection_log.dart';
import '../notification/notification_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _appBreakdown;
  String _displayName = 'Pengguna';
  List<Map<String, dynamic>> _daily = const [];
  bool _isLoadingStats = true;
  bool _isLoadingWeekly = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadDisplayName();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoadingStats = true;
      _isLoadingWeekly = true;
    });

    // Simulate network delay using manual dummy data
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Dummy Data for Statistics
    setState(() {
      _stats = {
        'totalGrandTotal': 125,
        'totalLow': 80,
        'totalMedium': 30,
        'totalHigh': 15,
        'appBreakdown': {
          'YouTube': {'Total': 50},
          'Instagram': {'Total': 40},
          'WhatsApp': {'Total': 20},
          'Chrome': {'Total': 15},
        }
      };
      
      _appBreakdown = (_stats?['appBreakdown'] as Map?)?.cast<String, dynamic>();
      _isLoadingStats = false;
      
      // Dummy Data for Weekly Breakdown
      _daily = [
        {'date': '2025-01-01', 'total': 45, 'high': 5, 'medium': 10, 'low': 30},
        {'date': '2024-12-31', 'total': 38, 'high': 2, 'medium': 8, 'low': 28},
        {'date': '2024-12-30', 'total': 50, 'high': 8, 'medium': 12, 'low': 30},
        {'date': '2024-12-29', 'total': 25, 'high': 1, 'medium': 4, 'low': 20},
        {'date': '2024-12-28', 'total': 60, 'high': 10, 'medium': 15, 'low': 35},
        {'date': '2024-12-27', 'total': 30, 'high': 3, 'medium': 7, 'low': 20},
        {'date': '2024-12-26', 'total': 40, 'high': 4, 'medium': 11, 'low': 25},
      ];
      _isLoadingWeekly = false;
    });
    
    print('Dashboard loaded with DUMMY DATA');
  }

  Future<void> refreshStats() async {
    // Just reload the dummy data
    await _loadStats();
  }

  Future<void> _loadDisplayName() async {
    // Dummy display name
    setState(() => _displayName = 'Zikri (Dummy)');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final isSmallScreen = screenHeight < 700;
    final isExtraSmall = screenHeight < 620;
    final isExtraSmallWidth = screenWidth < 360; // Very small phones
    final headerHeight = screenHeight * (isExtraSmall ? 0.10 : 0.12);
    final cardHeight = screenHeight * (isExtraSmall ? 0.11 : 0.13);
    final chartHeight = screenHeight * (isExtraSmall ? 0.07 : 0.08);
    final cardSpacing = isExtraSmallWidth ? 6.0 : (isSmallScreen ? 8.0 : 12.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: headerHeight.clamp(80.0, 120.0) + MediaQuery.of(context).padding.top,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A3B82F6),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Halo, $_displayName',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFF9FAFB),
                              fontSize: isExtraSmall ? 18 : 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hari ini: ${(_stats?['totalGrandTotal'] ?? '-') } deteksi',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFE5E7EB),
                              fontSize: isExtraSmall ? 11 : 12,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5177C1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshStats,
              color: const Color(0xFF3B82F6),
              child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                top: isSmallScreen ? 10 : 15,
                bottom: screenHeight * 0.15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistik Hari ini',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 15),
                  // Statistics Cards with Skeleton Loading
                  _isLoadingStats
                      ? Wrap(
                          spacing: cardSpacing,
                          runSpacing: cardSpacing,
                          children: List.generate(
                            4,
                            (index) => SizedBox(
                              width: (screenWidth - (screenWidth * 0.1) - cardSpacing) / 2,
                              child: SkeletonStatCard(
                                height: cardHeight.clamp(90.0, 110.0),
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: cardSpacing,
                          runSpacing: cardSpacing,
                          children: [
                            SizedBox(
                              width: (screenWidth - (screenWidth * 0.1) - cardSpacing) / 2,
                              child: StatCard(
                                count: (_stats?['totalGrandTotal'] ?? '-').toString(),
                                title: 'Total',
                                subtitle: 'Semua Level',
                                color: const Color(0xFF2E6FED),
                                icon: Icons.search,
                                height: cardHeight.clamp(90.0, 110.0),
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                            SizedBox(
                              width: (screenWidth - (screenWidth * 0.1) - cardSpacing) / 2,
                              child: StatCard(
                                count: (_stats?['totalLow'] ?? '-').toString(),
                                title: 'Low Risk',
                                subtitle: 'Aman',
                                color: const Color.fromARGB(255, 255, 230, 0),
                                icon: Icons.shield,
                                height: cardHeight.clamp(90.0, 110.0),
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                            SizedBox(
                              width: (screenWidth - (screenWidth * 0.1) - cardSpacing) / 2,
                              child: StatCard(
                                count: (_stats?['totalMedium'] ?? '-').toString(),
                                title: 'Medium Risk',
                                subtitle: 'Hati-hati',
                                color: const Color.fromARGB(255, 213, 107, 50),
                                icon: Icons.warning,
                                height: cardHeight.clamp(90.0, 110.0),
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                            SizedBox(
                              width: (screenWidth - (screenWidth * 0.1) - cardSpacing) / 2,
                              child: StatCard(
                                count: (_stats?['totalHigh'] ?? '-').toString(),
                                title: 'High Risk',
                                subtitle: 'Bahaya',
                                color: const Color.fromARGB(255, 244, 0, 0),
                                icon: Icons.dangerous,
                                height: cardHeight.clamp(90.0, 110.0),
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                          ],
                        ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  SectionHeader(
                    title: 'Tren 7 Hari Terakhir',
                    isSmallScreen: isSmallScreen,
                    onDetail: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryDetailScreen(
                            title: 'Trend 7 Hari Terakhir',
                            type: 'weekly',
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  // Weekly Chart with Skeleton Loading
                  _isLoadingWeekly
                      ? SkeletonWeeklyChart(height: chartHeight.clamp(180.0, 240.0))
                      : WeeklyBarChart(
                          daily: _daily,
                          height: chartHeight.clamp(180.0, 240.0),
                        ),
                  SizedBox(height: isSmallScreen ? 15 : 20),
                  SectionHeader(
                    title: 'Aplikasi Terdeteksi',
                    isSmallScreen: isSmallScreen,
                    onDetail: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryDetailScreen(
                            title: 'Aplikasi Terdeteksi',
                            type: 'apps',
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  // App Cards with Skeleton Loading
                  ...(_isLoadingStats
                      ? List.generate(
                          2,
                          (index) => Padding(
                            padding: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
                            child: SkeletonAppCard(
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                        )
                      : _buildTopApps(isSmallScreen)),
                  SizedBox(height: isSmallScreen ? 15 : 20),
                  SectionHeader(
                    title: 'Activity Terbaru',
                    isSmallScreen: isSmallScreen,
                    onDetail: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryDetailScreen(
                            title: 'Activity Terbaru',
                            type: 'activity',
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  ActivityCard(
                    time: '15:30',
                    appName: 'YouTube',
                    action: 'Aplikasi di Blokir',
                    riskLevel: 'Medium',
                    riskColor: const Color(0xFFF59E0B),
                    backgroundColor: const Color(0xFFFEF3C7),
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  ActivityCard(
                    time: '15:30',
                    appName: 'YouTube',
                    action: 'User Abaikan',
                    riskLevel: 'Medium',
                    riskColor: const Color(0xFFF59E0B),
                    backgroundColor: const Color(0xFFFEF3C7),
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTopApps(bool isSmallScreen) {
    if (_appBreakdown == null || _appBreakdown!.isEmpty) {
      return [
        Text(
          'Belum ada data aplikasi',
          style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 12),
        )
      ];
    }

    // Convert to list and sort by Total desc
    final entries = _appBreakdown!.entries.toList();
    entries.sort((a, b) {
      final aTotal = (a.value['Total'] ?? 0) as int;
      final bTotal = (b.value['Total'] ?? 0) as int;
      return bTotal.compareTo(aTotal);
    });

    // Take top 2 for compact view
    final top = entries.take(2);
    final List<Widget> cards = [];
    for (final e in top) {
      final name = e.key;
      final total = (e.value['Total'] ?? 0).toString();
      // Universal colors (no risk-based colors)
      const bgColor = Color(0xFFF3F4F6); // neutral gray-100
      const riskColor = Color(0xFF3B82F6); // blue accent for icon/percentage
      const riskLabel = '';

      final icon = name.toLowerCase().contains('you')
          ? Icons.play_arrow
          : name.toLowerCase().contains('insta')
              ? Icons.camera_alt
              : name.toLowerCase().contains('face')
                  ? Icons.facebook
                  : name.toLowerCase().contains('twit') || name.toLowerCase() == 'x'
                      ? Icons.close
                      : Icons.apps;

      cards.add(
        AppCard(
          appName: _capitalize(name),
          detections: '$total deteksi',
          percentage: '',
          riskLevel: riskLabel,
          riskColor: riskColor,
          backgroundColor: bgColor,
          icon: icon,
          isSmallScreen: isSmallScreen,
        ),
      );
      cards.add(SizedBox(height: isSmallScreen ? 6 : 8));
    }

    // Remove last spacer
    if (cards.isNotEmpty) cards.removeLast();
    return cards;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
