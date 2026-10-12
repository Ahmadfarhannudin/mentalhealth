
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Minimalist peaceful nature background.
/// Cocok untuk aplikasi kesehatan mental Tenang.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _BackgroundPainter(),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  const _BackgroundPainter();

  static const Color _sky = Color(0xFFF2F5ED);
  static const Color _cream = Color(0xFFF8F7EF);
  static const Color _hillBack = Color(0xFFE2EBD9);
  static const Color _hillMid = Color(0xFFCADDBB);
  static const Color _hillFront = Color(0xFFB4CEA1);

  static const Color _treeFar = Color(0xFFADC2A2);
  static const Color _treeMid = Color(0xFF88A57C);
  static const Color _treeFront = Color(0xFF668866);
  static const Color _trunk = Color(0xFF9B8067);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background dasar yang lembut.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = _sky,
    );

    // Nuansa hangat di tengah tanpa gradasi yang mencolok.
    canvas.drawCircle(
      Offset(w * 0.88, h * 0.13),
      w * 0.19,
      Paint()..color = _cream.withValues(alpha: 0.7),
    );

    // 2. Matahari samar di pojok kanan atas.
    canvas.drawCircle(
      Offset(w * 0.85, h * 0.105),
      w * 0.042,
      Paint()..color = const Color(0xFFE7E7C9),
    );

    canvas.drawCircle(
      Offset(w * 0.85, h * 0.105),
      w * 0.060,
      Paint()..color =
          const Color(0xFFE7E7C9).withValues(alpha: 0.22),
    );

    // 3. Bukit jauh.
    _drawHill(
      canvas,
      size,
      base: 0.80,
      amplitude: 0.026,
      phase: 0.6,
      color: _hillBack,
    );

    // Hanya beberapa pohon kecil di kejauhan.
    _drawPine(
      canvas,
      Offset(w * 0.13, _hillY(size, 0.80, 0.026, 0.6, w * 0.13)),
      h * 0.047,
      _treeFar,
    );

    _drawPine(
      canvas,
      Offset(w * 0.76, _hillY(size, 0.80, 0.026, 0.6, w * 0.76)),
      h * 0.038,
      _treeFar,
    );

    // 4. Bukit tengah.
    _drawHill(
      canvas,
      size,
      base: 0.875,
      amplitude: 0.028,
      phase: 2.2,
      color: _hillMid,
    );

    // Dua pohon berukuran sedang, tidak berjejer rapat.
    _drawRoundTree(
      canvas,
      Offset(
        w * 0.27,
        _hillY(size, 0.875, 0.028, 2.2, w * 0.27),
      ),
      h * 0.067,
      _treeMid,
    );

    _drawPine(
      canvas,
      Offset(
        w * 0.87,
        _hillY(size, 0.875, 0.028, 2.2, w * 0.87),
      ),
      h * 0.075,
      _treeMid,
    );

    // 5. Bukit depan sebagai aksen di bagian bawah.
    _drawHill(
      canvas,
      size,
      base: 0.955,
      amplitude: 0.017,
      phase: -0.7,
      color: _hillFront,
    );

    // Satu pohon pinus di sisi kiri.
    _drawPine(
      canvas,
      Offset(w * 0.075, h * 0.976),
      h * 0.105,
      _treeFront,
    );

    // Satu pohon rindang di sisi kanan.
    _drawRoundTree(
      canvas,
      Offset(w * 0.925, h * 0.973),
      h * 0.090,
      _treeFront,
    );

    // 6. Semak kecil untuk membuat lanskap lebih alami.
    _drawBush(
      canvas,
      Offset(w * 0.42, h * 0.980),
      w * 0.050,
      const Color(0xFF8EAB7D),
    );

    _drawBush(
      canvas,
      Offset(w * 0.69, h * 0.983),
      w * 0.060,
      const Color(0xFF96B184),
    );

    // 7. Rumput tipis dan jarang di foreground.
    _drawGrass(canvas, size);

    // 8. Ranting dekoratif yang sangat halus.
    _drawBranch(
      canvas,
      start: Offset(w * 1.02, h * 0.015),
      control: Offset(w * 0.94, h * 0.055),
      end: Offset(w * 0.83, h * 0.17),
      leafLength: w * 0.027,
      count: 5,
    );

    _drawBranch(
      canvas,
      start: Offset(-w * 0.015, h * 0.31),
      control: Offset(w * 0.045, h * 0.34),
      end: Offset(w * 0.11, h * 0.39),
      leafLength: w * 0.021,
      count: 3,
    );
  }

  double _hillY(
    Size size,
    double base,
    double amplitude,
    double phase,
    double x,
  ) {
    return size.height * base -
        size.height *
            amplitude *
            math.sin(x / size.width * 2 * math.pi + phase);
  }

  void _drawHill(
    Canvas canvas,
    Size size, {
    required double base,
    required double amplitude,
    required double phase,
    required Color color,
  }) {
    final path = Path()..moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 4) {
      path.lineTo(
        x,
        _hillY(size, base, amplitude, phase, x),
      );
    }

    path
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawPine(
    Canvas canvas,
    Offset base,
    double height,
    Color color,
  ) {
    final trunkPaint = Paint()..color = _trunk;

    canvas.drawRect(
      Rect.fromLTWH(
        base.dx - height * 0.025,
        base.dy - height * 0.17,
        height * 0.05,
        height * 0.17,
      ),
      trunkPaint,
    );

    final paint = Paint()..color = color;
    final width = height * 0.37;

    for (int i = 0; i < 3; i++) {
      final top = base.dy - height + i * height * 0.25;
      final bottom = top + height * 0.48;
      final halfWidth = width * (0.52 + i * 0.25);

      final path = Path()
        ..moveTo(base.dx, top)
        ..lineTo(base.dx - halfWidth, bottom)
        ..quadraticBezierTo(
          base.dx,
          bottom - height * 0.07,
          base.dx + halfWidth,
          bottom,
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  void _drawRoundTree(
    Canvas canvas,
    Offset base,
    double height,
    Color color,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(
        base.dx - height * 0.028,
        base.dy - height * 0.38,
        height * 0.056,
        height * 0.38,
      ),
      Paint()..color = _trunk,
    );

    final paint = Paint()..color = color;

    canvas.drawCircle(
      Offset(base.dx, base.dy - height * 0.58),
      height * 0.25,
      paint,
    );

    canvas.drawCircle(
      Offset(base.dx - height * 0.19, base.dy - height * 0.47),
      height * 0.22,
      paint,
    );

    canvas.drawCircle(
      Offset(base.dx + height * 0.19, base.dy - height * 0.47),
      height * 0.22,
      paint,
    );

    canvas.drawCircle(
      Offset(base.dx + height * 0.02, base.dy - height * 0.76),
      height * 0.20,
      paint,
    );
  }

  void _drawBush(
    Canvas canvas,
    Offset base,
    double width,
    Color color,
  ) {
    final paint = Paint()..color = color;

    canvas.drawCircle(
      Offset(base.dx - width * 0.25, base.dy - width * 0.12),
      width * 0.22,
      paint,
    );

    canvas.drawCircle(
      Offset(base.dx, base.dy - width * 0.23),
      width * 0.30,
      paint,
    );

    canvas.drawCircle(
      Offset(base.dx + width * 0.25, base.dy - width * 0.12),
      width * 0.22,
      paint,
    );
  }

  void _drawGrass(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6F9168).withValues(alpha: 0.42)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Rumput ditempatkan dengan jarak yang teratur.
    for (int i = 0; i < 19; i++) {
      final x = size.width * (i + 0.5) / 19;
      final y = size.height * (0.978 + (i % 3) * 0.004);
      final len = size.height * (0.007 + (i % 2) * 0.003);

      canvas.drawLine(
        Offset(x, y),
        Offset(x - len * 0.25, y - len),
        paint,
      );

      canvas.drawLine(
        Offset(x, y),
        Offset(x + len * 0.30, y - len * 0.8),
        paint,
      );
    }
  }

  void _drawBranch(
    Canvas canvas, {
    required Offset start,
    required Offset control,
    required Offset end,
    required double leafLength,
    required int count,
  }) {
    final branchPaint = Paint()
      ..color = const Color(0xFF8DA78C).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(
          control.dx,
          control.dy,
          end.dx,
          end.dy,
        ),
      branchPaint,
    );

    final leafPaint = Paint()
      ..color = const Color(0xFF8DA78C).withValues(alpha: 0.30);

    for (int i = 1; i <= count; i++) {
      final t = i / (count + 1);
      final mt = 1 - t;

      final x = mt * mt * start.dx +
          2 * mt * t * control.dx +
          t * t * end.dx;

      final y = mt * mt * start.dy +
          2 * mt * t * control.dy +
          t * t * end.dy;

      final dx = 2 * mt * (control.dx - start.dx) +
          2 * t * (end.dx - control.dx);

      final dy = 2 * mt * (control.dy - start.dy) +
          2 * t * (end.dy - control.dy);

      final angle = math.atan2(dy, dx);
      final side = i.isEven ? 1.0 : -1.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + side * 0.9);

      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(
            leafLength * 0.5,
            -leafLength * 0.4,
            leafLength,
            0,
          )
          ..quadraticBezierTo(
            leafLength * 0.5,
            leafLength * 0.4,
            0,
            0,
          ),
        leafPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => false;
}
