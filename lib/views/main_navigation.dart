import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'screens/dashboard/parent_dashboard_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/profile/parent_profile_page.dart';
import 'screens/monitoring/monitoring_screen.dart';
import 'screens/chatbot/ai_chatbot_screen.dart';
import '../services/monitoring/auto_screenshot_service.dart';
import '../services/storage/secure_storage_service.dart';
import '../models/login.dart';

class HomeScreen extends StatefulWidget {
  final String? initialRole;
  const HomeScreen({super.key, this.initialRole});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _pages = [];
  List<BottomNavigationBarItem> _navItems = [];
  final GlobalKey<DashboardPageState> _dashboardKey =
      GlobalKey<DashboardPageState>();

  bool _isLoading = true;
  String _userRole = 'child'; // Default

  @override
  void initState() {
    super.initState();
    // Initialize GetX controller for monitoring
    Get.put(AutoScreenshotService());

    _initUserRole();
  }

  Future<void> _initUserRole() async {
    // If specific role is passed via constructor (for testing/routing), use it
    if (widget.initialRole != null) {
      setState(() {
        _userRole = widget.initialRole!;
        _setupNavigation(_userRole);
        _isLoading = false;
      });
      return;
    }

    final LoginUser? user = await SecureStorageService.getUserData();
    final role = user?.role ?? 'child';

    setState(() {
      _userRole = role;
      _setupNavigation(role);
      _isLoading = false;
    });
  }

  void _setupNavigation(String role) {
    if (role == 'parent') {
      _pages = [
        const ParentDashboardPage(),
        // Monitoring screen for parents to see child's activity
        const MonitoringScreen(),
        const ParentProfilePage(),
      ];
      _navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.remove_red_eye_rounded),
          label: 'Monitoring',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ];
    } else {
      // Child Role
      _pages = [
        DashboardPage(key: _dashboardKey),
        const AiChatbotScreen(),
        const ProfilePage(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy_rounded),
          label: 'AI Chatbot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          if (_userRole == 'child' && _currentIndex == index && index == 0) {
            // Re-selecting Dashboard: refresh statistics (only for child dashboard)
            _dashboardKey.currentState?.refreshStats();
          }
          _currentIndex = index;
        }),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3F88EB),
        unselectedItemColor: const Color(0xFF979797),
        selectedLabelStyle: GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: _navItems,
      ),
    );
  }
}
