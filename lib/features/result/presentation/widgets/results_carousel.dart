import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/consts.dart';
import '../../../../core/widgets/gradient_border_button.dart';
import '../../domain/entities/garment_result.dart';

class ResultsCarousel extends StatefulWidget {
  const ResultsCarousel({
    super.key,
    required this.results,
    required this.onTryAgain,
  });

  final List<GarmentResult> results;
  final VoidCallback onTryAgain;

  @override
  State<ResultsCarousel> createState() => _ResultsCarouselState();
}

class _ResultsCarouselState extends State<ResultsCarousel> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.results.length,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (context, index) {
            return _ResultCard(
              result: widget.results[index],
              index: index,
              total: widget.results.length,
            );
          },
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.results.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: i == _currentPage ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: i == _currentPage ? Colors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.screenHorizontalPadding,
          right: AppSpacing.screenHorizontalPadding,
          bottom: MediaQuery.of(context).padding.bottom + 24,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onTryAgain,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try Again'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GradientBorderButton(
                  onPressed: () =>
                      _saveImage(context, widget.results[_currentPage]),
                  icon: Icons.download,
                  label: 'Download',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveImage(BuildContext context, GarmentResult result) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'unworn_${result.title.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(result.imageBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Look saved to your device ✓',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Couldn\'t save this time — try again',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.index,
    required this.total,
  });

  final GarmentResult result;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(
          result.imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.broken_image, size: 64, color: Colors.white24),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.2, 0.6, 1.0],
              colors: [
                Colors.transparent,
                Color(0x99000000),
                Color(0xDD000000),
              ],
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.screenHorizontalPadding,
          right: AppSpacing.screenHorizontalPadding,
          top: 0,
          bottom: 120,
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.12],
              colors: [Colors.transparent, Colors.white],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              reverse: true,
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.occasion,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 10),
                  Text(
                        result.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    result.style,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
                  const SizedBox(height: 6),
                  Text(
                    result.transformation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                      height: 1.4,
                    ),
                  ).animate(delay: 350.ms).fadeIn(duration: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
