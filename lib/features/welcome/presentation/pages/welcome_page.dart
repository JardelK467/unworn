import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/consts.dart';
import '../widgets/camera_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: WelcomeSpacing.titleTopPadding),
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: WelcomeSpacing.titleFontSize,
                  fontWeight: WelcomeSpacing.titleFontWeight,
                  letterSpacing: WelcomeSpacing.titleLetterSpacing,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
              const SizedBox(height: WelcomeSpacing.taglineGap),
              Text(
                AppConstants.tagline,
                style: TextStyle(
                  fontSize: WelcomeSpacing.taglineFontSize,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 600.ms),
              const Spacer(),
              CameraButton(onTap: () => context.go('/info'))
                  .animate(delay: 800.ms)
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: WelcomeSpacing.pillGap),
              Container(
                width: double.infinity,
                height: WelcomeSpacing.pillHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Press the button to continue',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ).animate(delay: 1000.ms).fadeIn(duration: 500.ms),
              const Spacer(),
              Container(
                width: double.infinity,
                height: AppSpacing.accentBarHeight,
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
