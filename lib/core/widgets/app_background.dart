import 'package:flutter/material.dart';

import '../constants/consts.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/9782010.jpg',
            fit: BoxFit.cover,
            color: AppColors.background.withValues(alpha: 0.88),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        child,
      ],
    );
  }
}
