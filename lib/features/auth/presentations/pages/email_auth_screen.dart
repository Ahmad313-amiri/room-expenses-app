import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomly/features/auth/presentations/pages/verify_email_screen.dart';
import '../../../../core/util/error_handler.dart';
import '../../data/repository/authentication_repository.dart';
import '../widgets/login_controller.dart';
import '../widgets/sign_up_controller.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  bool isLogin = true;
  bool obscurePassword = true;
  final SignUpController signUpController = Get.find<SignUpController>();
  final SignInController signInController = Get.find<SignInController>();
  final authRepo = Get.find<AuthenticationRepository>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildTabToggle(),
            const SizedBox(height: 48),
            Text(
              isLogin ? 'Welcome back' : 'Create account',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
            ),
            const SizedBox(height: 12),
            Text(
              isLogin ? 'Log in to manage your debts.' : 'Join us to split expenses effortlessly.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            if (!isLogin) ...[
              _buildLabel('FULL NAME'),
              _buildTextField(controller: signUpController.userName, hint: 'John Doe'),
              const SizedBox(height: 24),
            ],
            _buildLabel('EMAIL'),
            _buildTextField(
              controller: isLogin ? signInController.email : signUpController.email,
              hint: 'you@example.com',
            ),
            const SizedBox(height: 24),
            _buildLabel('PASSWORD'),
            _buildPasswordField(),
            if (isLogin)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showForgotPasswordDialog(),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Color(0xFF1D5CFF), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            const SizedBox(height: 40),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: authRepo.isSubmitting.value ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D5CFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: authRepo.isSubmitting.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isLogin ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )),
            const SizedBox(height: 40),
            _buildLegalText(),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email address and we’ll send you a link to reset your password.'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                enabled: !isLoading,
              ),
              if (isLoading) const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  ErrorHandler.handleValidationError('Please enter your email');
                  return;
                }
                setState(() => isLoading = true);
                try {
                  await authRepo.sendPasswordResetEmail(email);
                  if (context.mounted) Navigator.pop(context);
                  ErrorHandler.showSuccess('Email Sent', 'Check your inbox to reset your password.');
                } catch (e) {
                  ErrorHandler.handleError('Error', e.toString());
                } finally {
                  if (context.mounted) setState(() => isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D5CFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    try {
      bool success;
      if (isLogin) {
        success = await signInController.loginUserController(
          signInController.email.text.trim(),
          signInController.password.text.trim(),
        );
        if (success && mounted) {
         Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        success = await signUpController.registerUser(
          signUpController.email.text.trim(),
          signUpController.password.text.trim(),
          signUpController.userName.text.trim(),
        );
        if (success && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
          );
        }
      }
    } catch (e) {
    }
  }

  Future<void> _showVerificationDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Verify Your Email', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.email_outlined, size: 64, color: Color(0xFF1D5CFF)),
            const SizedBox(height: 16),
            const Text(
              'We sent a verification link to your email address.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              signUpController.email.text.trim(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please verify your email before logging in.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await authRepo.resendVerificationEmail();
                ErrorHandler.showSuccess('Email Sent', 'A new verification link has been sent.');
              } catch (e) {
                ErrorHandler.handleError('Error', e.toString());
              }
            },
            child: const Text('Resend Email'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D5CFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isLogin = true),
              child: Container(
                decoration: BoxDecoration(
                  color: isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isLogin ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Log In',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isLogin ? Colors.black : Colors.grey),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isLogin = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isLogin ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontWeight: FontWeight.bold, color: !isLogin ? Colors.black : Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEAECF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1D5CFF), width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: isLogin ? signInController.password : signUpController.password,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        hintText: '••••••••',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        suffixIcon: IconButton(
          icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
          onPressed: () => setState(() => obscurePassword = !obscurePassword),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEAECF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1D5CFF), width: 2),
        ),
      ),
    );
  }

  Widget _buildLegalText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          children: [
            TextSpan(text: 'By continuing, you agree to our\n'),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}