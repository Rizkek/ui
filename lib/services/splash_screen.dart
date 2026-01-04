// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../views/widgets/auth_wrapper.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // Set status bar to transparent
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.light,
//       ),
//     );

//     // Initialize animations - faster loading
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1200), // Reduced from 2000ms
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
//       ),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
//       ),
//     );

//     // Start animation
//     _animationController.forward();

//     // Navigate to next screen after delay
//     _navigateToNext();
//   }

//   void _navigateToNext() {
//     Future.delayed(const Duration(milliseconds: 1800), () {
//       // Reduced from 3000ms
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const AuthWrapper()),
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF4A90E2), // Light blue
//               Color(0xFF357ABD), // Darker blue
//             ],
//           ),
//         ),
//         child: AnimatedBuilder(
//           animation: _animationController,
//           builder: (context, child) {
//             return FadeTransition(
//               opacity: _fadeAnimation,
//               child: ScaleTransition(
//                 scale: _scaleAnimation,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Logo Container
//                     Container(
//                       width: 180,
//                       height: 180,
//                       child: Image.asset(
//                         'assets/images/Paradise_logo.png',
//                         width: 140,
//                         height: 140,
//                         fit: BoxFit.contain,
//                         errorBuilder: (context, error, stackTrace) {
//                           // Fallback widget if image not found - simple icon only
//                           return const Icon(
//                             Icons.shield,
//                             size: 80,
//                             color: Colors.white,
//                           );
//                         },
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // Tagline
//                     const Text(
//                       'Your Privacy Guardian',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white70,
//                         letterSpacing: 1,
//                       ),
//                     ),

//                     const SizedBox(height: 60),

//                     // Loading indicator
//                     const SizedBox(
//                       width: 30,
//                       height: 30,
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         strokeWidth: 3,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
