import 'package:flutter/material.dart';

class AnimatedLogo extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> fadeAnimation;
  final Animation<double> slideAnimation;

  const AnimatedLogo({
    super.key,
    required this.controller,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, slideAnimation.value),
          child: Opacity(
            opacity: fadeAnimation.value,
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white, theme.colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.account_balance_wallet, size: 60, color: theme.colorScheme.onPrimary),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'SplitEase',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.2))],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Split expenses with friends',
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
