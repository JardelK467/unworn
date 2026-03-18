import 'package:flutter/material.dart';

class TiledBackground extends StatelessWidget {
  const TiledBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: const _TiledPatternPainter()),
    );
  }
}

class _TiledPatternPainter extends CustomPainter {
  const _TiledPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 44.0;
    const shapeSize = 14.0;

    for (var x = 0.0; x < size.width + spacing; x += spacing) {
      for (var y = 0.0; y < size.height + spacing; y += spacing) {
        final path = Path()
          ..moveTo(x, y - shapeSize / 2)
          ..lineTo(x + shapeSize / 2, y)
          ..lineTo(x, y + shapeSize / 2)
          ..lineTo(x - shapeSize / 2, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
