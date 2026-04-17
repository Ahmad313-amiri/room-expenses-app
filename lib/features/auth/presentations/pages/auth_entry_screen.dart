import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/login_controller.dart';
import 'email_auth_screen.dart';

class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignInController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header section with logo and title
              _buildHeader(),
              const SizedBox(height: 50),
              // Social login buttons
              _buildSocialButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                // In real project, use image instead
                color: Colors.red,
                onTap: () => controller.loginWithGoogle(),
              ),
              const SizedBox(height: 20),
              _buildSocialButton(
                label: 'Continue with Email',
                icon: Icons.email_outlined,
                // In real project, use image instead
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmailAuthScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header with logo and text
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1D5CFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Master Your Debt',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage, split and track with ease.',
          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
        ),
      ],
    );
  }

  // Social login button builder
  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
