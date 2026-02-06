import 'package:flutter/material.dart';
import 'package:roomly/features/dashboard/presentation/pages/phone_otp_auth_screen.dart';

import 'emial_auth_screen.dart';

class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Header section with logo and title
              _buildHeader(),
              const Spacer(flex: 1),
              // Social login buttons
              _buildSocialButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata, // In real project, use image instead
                color: Colors.red,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                label: 'Continue with Apple',
                icon: Icons.apple,
                color: Colors.black,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              // Primary login with Email
              _buildPrimaryButton(
                label: 'Continue with Email',
                icon: Icons.email_outlined,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EmailAuthScreen()));
                },
              ),
              const SizedBox(height: 24),
              // Phone number login link
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PhoneOtpVerificationScreen()));
                },
                child: const Text(
                  'Use Phone Number Instead',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              const Spacer(flex: 2),
              // Offline mode option at the bottom
              _buildOfflineOption(context),
              const SizedBox(height: 20),
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
          child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          'Master Your Debt',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
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
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // Primary button builder (Email login)
  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D5CFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  // Offline mode option at the bottom
  Widget _buildOfflineOption(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Don't want an account?",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            // Navigate directly to dashboard without account
          },
          child: const Text(
            'Skip & Use Offline',
            style: TextStyle(
              color: Color(0xFF101828),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
