import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/consts.dart';
import '../../../../core/widgets/gradient_border_button.dart';
import '../widgets/info_card.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  static const _infoItems = [
    (
      icon: Icons.camera_alt_outlined,
      title: 'Camera Access',
      description:
          'We\'ll need access to your camera to capture a photo of your garment.',
    ),
    (
      icon: Icons.auto_awesome_outlined,
      title: 'Image Analysis',
      description:
          'Your garment photo will be analysed by AI to generate creative style concepts.',
    ),
    (
      icon: Icons.cloud_off_outlined,
      title: 'Data Storage',
      description:
          'Images are processed in real-time. Nothing is stored on our servers.',
    ),
    (
      icon: Icons.shield_outlined,
      title: 'Privacy',
      description:
          'Your photos never leave the analysis pipeline. We respect your privacy.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: InfoSpacing.headingTopPadding),
                  Text(
                    'Before You\nContinue',
                    style: const TextStyle(
                      fontSize: InfoSpacing.headingFontSize,
                      fontWeight: InfoSpacing.headingFontWeight,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: InfoSpacing.headingToCards),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                itemCount: _infoItems.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: InfoSpacing.cardGap),
                itemBuilder: (context, index) {
                  final item = _infoItems[index];
                  return InfoCard(
                        icon: item.icon,
                        title: item.title,
                        description: item.description,
                      )
                      .animate(delay: (200 + index * 100).ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.05, end: 0);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontalPadding,
                InfoSpacing.buttonVerticalPadding,
                AppSpacing.screenHorizontalPadding,
                InfoSpacing.buttonVerticalPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: InfoSpacing.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                  const SizedBox(width: InfoSpacing.buttonGap),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: InfoSpacing.buttonHeight,
                      child: GradientBorderButton(
                        onPressed: () => context.go('/camera'),
                        label: 'I Understand',
                        borderRadius: AppSpacing.pillRadius,
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}
