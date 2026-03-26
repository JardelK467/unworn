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
          child: SizedBox(
            height: WelcomeSpacing.pillHeight,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onTryAgain,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 18),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Try Again',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: WelcomeSpacing.pillHeight,
                    child: GradientBorderButton(
                      onPressed: () =>
                          _saveImage(context, widget.results[_currentPage]),
                      icon: Icons.download,
                      label: 'Download',
                    ),
                  ),
                ),
              ],
            ),
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

class _ResultCard extends StatefulWidget {
  const _ResultCard({
    required this.result,
    required this.index,
    required this.total,
  });

  final GarmentResult result;
  final int index;
  final int total;

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
  bool _showText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _showText = !_showText),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            widget.result.imageBytes,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Center(
              child: Icon(Icons.broken_image, size: 64, color: Colors.white24),
            ),
          ),
          AnimatedOpacity(
            opacity: _showText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.45, 0.75, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0x99000000),
                    Color(0xDD000000),
                  ],
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _showText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_showText,
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.screenHorizontalPadding,
                  right: AppSpacing.screenHorizontalPadding,
                  bottom: 120,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                        widget.result.occasion,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 10),
                    Text(
                          widget.result.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      widget.result.style,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
                    const SizedBox(height: 6),
                    Text(
                      widget.result.transformation,
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
          ),
          // Hint icon when text is hidden
          if (!_showText)
            Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: Center(
                child: Icon(
                  Icons.touch_app_outlined,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 28,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
