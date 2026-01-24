import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String iconPath;
  final String label;

  const SocialButton({super.key, required this.iconPath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Image.asset(iconPath, width: 24, height: 24),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
