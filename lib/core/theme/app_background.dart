import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Quiet background: warm paper, one soft light wash, and a single distant
/// horizon line. No scenery, no pattern, no glow.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _CalmBackgroundPainter()),
          ),
        ),
        child,
      ],
    );
  }
}

class _CalmBackgroundPainter extends CustomPainter {
  const _CalmBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = AppColors.canvas);

    final mint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.forestPale.withValues(alpha: 0.55),
              AppColors.forestPale.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.12, size.height * 0.04),
              radius: size.width * 0.85,
            ),
          );
    canvas.drawRect(rect, mint);

    final warm = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.clayPale.withValues(alpha: 0.45),
              AppColors.clayPale.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 1.05, size.height * 0.92),
              radius: size.width * 0.9,
            ),
          );
    canvas.drawRect(rect, warm);

    final horizon = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.78,
        size.width * 0.62,
        size.height * 0.815,
      )
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.84,
        size.width,
        size.height * 0.805,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      horizon,
      Paint()..color = AppColors.forestPale.withValues(alpha: 0.22),
    );

    final second = Path()
      ..moveTo(0, size.height * 0.90)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.86,
        size.width * 0.72,
        size.height * 0.895,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.915,
        size.width,
        size.height * 0.89,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      second,
      Paint()..color = AppColors.forestPale.withValues(alpha: 0.30),
    );
  }

  @override
  bool shouldRepaint(covariant _CalmBackgroundPainter oldDelegate) => false;
}

/// Soft organic arc used inside cards when a surface needs a nature cue.
class SoftArc extends StatelessWidget {
  final Color color;
  final double height;

  const SoftArc({
    super.key,
    this.color = AppColors.forestPale,
    this.height = 72,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _ArcPainter(color)),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;

  const _ArcPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.12,
        size.width * 0.55,
        size.height * 0.52,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.86,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.55));

    final line = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.86, size.height * 0.1),
        width: size.width * 0.5,
        height: size.height * 1.4,
      ),
      math.pi * 0.6,
      math.pi * 0.5,
      false,
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.color != color;
}
