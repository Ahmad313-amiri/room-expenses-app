import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneOtpVerificationScreen extends StatefulWidget {
  const PhoneOtpVerificationScreen({super.key});

  @override
  State<PhoneOtpVerificationScreen> createState() =>
      _PhoneOtpVerificationScreenState();
}

class _PhoneOtpVerificationScreenState
    extends State<PhoneOtpVerificationScreen> {
  // Tracks whether user agreed to terms and privacy policy
  bool _agreedToTerms = true;

  // OTP controllers (6-digit code)
  final List<TextEditingController> _otpControllers =
  List.generate(6, (index) => TextEditingController());

  // Focus nodes for automatic cursor movement
  final List<FocusNode> _focusNodes =
  List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();

    // Pre-filled OTP values (as shown in the design mockup)
    _otpControllers[0].text = "4";
    _otpControllers[1].text = "8";
    _otpControllers[2].text = "2";
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes to avoid memory leaks
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // App bar with back navigation
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verification',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Main title
            const Text(
              'Welcome back',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A)),
            ),

            const SizedBox(height: 12),

            // Description text
            const Text(
              'Enter your phone number to manage your debts securely. '
                  'Internet is only required for this step.',
              style: TextStyle(
                  fontSize: 15, color: Colors.blueGrey, height: 1.4),
            ),

            const SizedBox(height: 32),

            // PHONE DETAILS section label
            const Text(
              'PHONE DETAILS',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1),
            ),

            const SizedBox(height: 12),

            // Phone number input row
            Row(
              children: [
                // Country picker (static UI)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Text('🇺🇸', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('+1',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey, size: 18),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Phone number text field
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '555-0123',
                      filled: true,
                      fillColor: const Color(0xFFF2F4F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Terms & privacy checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: (val) =>
                        setState(() => _agreedToTerms = val!),
                    activeColor: const Color(0xFF1D5CFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'I agree to the Privacy Policy and Terms of Service '
                        'for secure debt management.',
                    style:
                    TextStyle(fontSize: 13, color: Colors.blueGrey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Send code button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D5CFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Send Code',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Verification code divider
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'VERIFICATION CODE',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 24),

            const Center(
              child: Text(
                'Enter the 6-digit code',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 4),

            const Center(
              child: Text(
                'Sent to your phone via SMS',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),

            const SizedBox(height: 24),

            // OTP input boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
              List.generate(6, (index) => _buildOtpBox(index)),
            ),

            const SizedBox(height: 24),

            // Resend code section
            Center(
              child: Column(
                children: [
                  const Text.rich(
                    TextSpan(
                      text: 'Resend code in ',
                      style:
                      TextStyle(color: Colors.grey, fontSize: 13),
                      children: [
                        TextSpan(
                          text: '00:48',
                          style: TextStyle(
                              color: Color(0xFF1D5CFF),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Didn\'t receive a code?',
                      style: TextStyle(
                          color: Color(0xFF1D5CFF),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Final verify button (disabled state UI)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF1D5CFF).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Verify & Continue',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Bottom circular illustration placeholder
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insert_drive_file_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Single OTP input box widget
  Widget _buildOtpBox(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style:
          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          decoration:
          const InputDecoration(counterText: "", border: InputBorder.none),
          onChanged: (value) {
            // Automatically move focus to next field
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}
