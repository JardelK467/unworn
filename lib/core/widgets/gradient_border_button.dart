import 'package:flutter/material.dart';

import '../../../core/constants/consts.dart';

class GradientBorderButton extends StatelessWidget {
  const GradientBorderButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.borderWidth = 2,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        painter: _GradientBorderPainter(
          colors: AppColors.gradientRing,
          strokeWidth: borderWidth,
          radius: borderRadius,
        ),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  const _GradientBorderPainter({
    required this.colors,
    required this.strokeWidth,
    required this.radius,
  });

  final List<Color> colors;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = SweepGradient(colors: colors).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) =>
      oldDelegate.colors != colors ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}
