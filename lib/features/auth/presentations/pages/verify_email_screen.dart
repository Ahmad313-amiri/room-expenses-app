import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/util/error_handler.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../data/repository/authentication_repository.dart';
import 'auth_entry_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final authRepo = Get.find<AuthenticationRepository>();
  Timer? _autoCheckTimer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startAutoCheck();
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  void _startAutoCheck() {
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await authRepo.refreshUser();
      if (authRepo.isEmailVerified.value && mounted) {
        timer.cancel();
        Get.offAll(() => const HomeScreen());
      }
    });
  }

  Future<void> _resendVerification() async {
    if (_isResending) return;
    setState(() => _isResending = true);
    try {
      await authRepo.resendVerificationEmail();
      ErrorHandler.showSuccess(
        'Email Sent',
        'A new verification link has been sent to your email address.',
      );
    } catch (e) {
          ErrorHandler.handleError('Could not resend email', e.toString());
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _logout() async {
    await authRepo.logout();
    Get.offAll(() => const AuthEntryScreen());
  }

  @override
  Widget build(BuildContext context) {
    final user = authRepo.firebaseUser.value;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _logout,
            child: Icon(Icons.arrow_forward,size: 25,),
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: Color(0xFF1D5CFF)),
              const SizedBox(height: 24),
              const Text('Verify Your Email', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('We sent a verification link to:', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),
              Text(user?.email ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
                        Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'If you don\'t see the email, please check your Spam/Junk folder.',
                        style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Please check your email and click the link to continue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Obx(() {
                if (authRepo.isEmailVerified.value) return const SizedBox.shrink();
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: _isResending ? null : _resendVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D5CFF),
                        minimumSize: const Size(200, 48),
                      ),
                      child: _isResending
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Resend Email',style: TextStyle(
                        color: Colors.white
                      ),),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => authRepo.refreshUser(),
                      child: const Text('I have verified, check now'),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}