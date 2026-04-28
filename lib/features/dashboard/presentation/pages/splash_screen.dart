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
   }




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

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
