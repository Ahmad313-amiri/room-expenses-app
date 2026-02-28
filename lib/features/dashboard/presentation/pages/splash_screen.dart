import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // _handleStartupLogic();
    _goNext();
  }



  // Navigate to next screen after a short delay
  Future<void> _goNext() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/authEntry');
    // Example:
    // '/auth'
    // '/home'
    // '/onboarding'
  }



  // // App startup decision logic
  // Future<void> _handleStartupLogic() async {
  //   // Simulate local data loading (DB, cache, token, etc.)
  //   await Future.delayed(const Duration(seconds: 2));
  //
  //   // TODO:
  //   // final isLoggedIn = await AuthStorage.isLoggedIn();
  //   // final isProfileCompleted = await UserStorage.isProfileCompleted();
  //
  //   final isLoggedIn = true; // demo
  //   final isProfileCompleted = false; // demo
  //
  //   if (!mounted) return;
  //
  //   if (!isLoggedIn){
  //     // User not authenticated
  //
  //     Navigator.pushReplacementNamed(context, '/);
  //   } else if (!isProfileCompleted) {
  //     // User logged in but profile not completed
  //     Navigator.pushReplacementNamed(context, '/profile-setup');
  //   } else {
  //     // User fully ready
  //     Navigator.pushReplacementNamed(context, '/home');
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Central content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo (Book icon in rounded container with shadow)
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE), // Light blue background
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D5CFF), // Main brand blue
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App name
                  const Text(
                    'Roomly',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // App tagline
                  const Text(
                    'Your Smart Digital Ledger',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Offline-first technology badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF1D5CFF),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'OFFLINE-FIRST TECHNOLOGY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom section
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 120),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.35, // Sample progress value
                        backgroundColor: Color(0xFFF2F4F7),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D5CFF)),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Footer text
                  Text(
                    'TRUSTED BY PROFESSIONALS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
