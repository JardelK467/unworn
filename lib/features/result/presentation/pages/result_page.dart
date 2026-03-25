import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/consts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/gradient_border_button.dart';
import '../cubit/result_cubit.dart';
import '../cubit/result_state.dart';
import '../widgets/results_carousel.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.imagePath, this.userPrompt});

  final String imagePath;
  final String? userPrompt;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ResultCubit>()..generate(imagePath, userPrompt: userPrompt),
      child: _ResultView(imagePath: imagePath, userPrompt: userPrompt),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.imagePath, this.userPrompt});

  final String imagePath;
  final String? userPrompt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<ResultCubit, ResultState>(
        builder: (context, state) {
          return switch (state) {
            ResultLoading(:final progress, :final stage) => _LoadingView(
              progress: progress,
              stage: stage,
            ),
            ResultLoaded(:final results) => ResultsCarousel(
              results: results,
              onTryAgain: () => context.go('/camera'),
            ),
            ResultError(:final type) => _ErrorView(
              type: type,
              onRetry: () => context.read<ResultCubit>().generate(
                imagePath,
                userPrompt: userPrompt,
              ),
            ),
          };
        },
      ),
    );
  }
}

class _LoadingView extends StatefulWidget {
  const _LoadingView({required this.progress, required this.stage});

  final double progress;
  final String stage;

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnimation;
  bool _showStage = false;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() => _showStage = !_showStage);
              _pulseController.forward(from: 0);
            }
          });
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 20),
    ]).animate(_pulseController);
    _pulseController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (widget.progress * 100).round();
    final stageText = widget.stage.isNotEmpty
        ? widget.stage
        : AppConstants.loadingMessage;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _GradientSpinner(size: 32, strokeWidth: 2),
                const SizedBox(width: 16),
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                _showStage ? stageText : AppConstants.loadingMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  letterSpacing: 1.5,
                  color: Colors.white38,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatefulWidget {
  const _ErrorView({required this.type, required this.onRetry});

  final ResultFailureType type;
  final VoidCallback onRetry;
  @override
  State<_ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<_ErrorView> {
  bool _supportSheetShown = false;

  @override
  void initState() {
    super.initState();
    _maybeShowQuotaSupportSheet();
  }

  @override
  void didUpdateWidget(covariant _ErrorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _supportSheetShown = false;
      _maybeShowQuotaSupportSheet();
    }
  }

  void _maybeShowQuotaSupportSheet() {
    if (widget.type != ResultFailureType.quotaExceeded || _supportSheetShown) {
      return;
    }
    _supportSheetShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showSupportSheet(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = switch (widget.type) {
      ResultFailureType.noInternet => (
        Icons.wifi_off_outlined,
        'No connection',
        'Check your internet and try again.',
      ),
      ResultFailureType.quotaExceeded => (
        Icons.error_outline,
        'Service unavailable',
        'We\'ve hit our limit for now. Contact us to get back on track.',
      ),
      ResultFailureType.invalidGarment => (
        Icons.checkroom_outlined,
        'We couldn\'t find a garment',
        'Try a clearer photo of a single item of clothing on a flat surface.',
      ),
      ResultFailureType.unknown => (
        Icons.auto_awesome_outlined,
        'Something went wrong',
        'We couldn\'t reimagine your garment this time.',
      ),
    };
    final mainActionLabel = switch (widget.type) {
      ResultFailureType.quotaExceeded => 'Contact Support',
      ResultFailureType.invalidGarment => 'Retake Photo',
      ResultFailureType.noInternet || ResultFailureType.unknown => 'Retry',
    };
    final VoidCallback mainActionOnPressed = switch (widget.type) {
      ResultFailureType.quotaExceeded => () => _showSupportSheet(context),
      ResultFailureType.invalidGarment => () => context.go('/camera'),
      ResultFailureType.noInternet || ResultFailureType.unknown => widget.onRetry,
    };
    final Widget? secondaryAction = switch (widget.type) {
      ResultFailureType.quotaExceeded => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: TextButton(
          onPressed: () => context.go('/'),
          child: Text(
            'Try Later',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white54),
          ),
        ),
      ),
      ResultFailureType.noInternet => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: TextButton(
          onPressed: openAppSettings,
          child: Text(
            'Open Settings',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white54),
          ),
        ),
      ),
      ResultFailureType.invalidGarment || ResultFailureType.unknown => null,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.purple.withValues(alpha: 0.12),
                  ),
                  child: Icon(icon, size: 32, color: AppColors.purple),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 500.ms),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: WelcomeSpacing.pillHeight,
              child: GradientBorderButton(
                onPressed: mainActionOnPressed,
                label: mainActionLabel,
                borderRadius: AppSpacing.pillRadius,
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
            if (secondaryAction != null)
              secondaryAction.animate(delay: 600.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.mail_outline, size: 40, color: AppColors.purple),
            const SizedBox(height: 16),
            Text(
              'Get in touch',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'jardelkerr@live.com',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.purple,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}

class _GradientSpinner extends StatefulWidget {
  const _GradientSpinner({this.size = 32, this.strokeWidth = 2});

  final double size;
  final double strokeWidth;

  @override
  State<_GradientSpinner> createState() => _GradientSpinnerState();
}

class _GradientSpinnerState extends State<_GradientSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _GradientArcPainter(
          colors: AppColors.gradientRing,
          strokeWidth: widget.strokeWidth,
        ),
      ),
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  const _GradientArcPainter({
    required this.colors,
    required this.strokeWidth,
  });

  final List<Color> colors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [colors.first.withValues(alpha: 0), ...colors],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      0,
      math.pi * 1.75,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientArcPainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.strokeWidth != strokeWidth;
}
