import 'dart:math' as math;

import 'package:flutter/material.dart';

class KwentoBackground extends StatelessWidget {
  const KwentoBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  final Widget child;
  final EdgeInsets padding;

  static const Color bg = Color(0xFF1EC7C9);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bg,
      child: Stack(
        children: [
          const Positioned.fill(child: _Sparkles()),
          const Positioned(left: 0, right: 0, bottom: 0, child: _Landscape()),
          SafeArea(
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sparkles extends StatelessWidget {
  const _Sparkles();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SparklesPainter(),
      ),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  static const _sparkleColor = Color(0xFFEAFBFF);
  static const _sparkleColor2 = Color(0xFFBFF2F6);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;

    void cross(Offset c, double r, double strokeWidth, Color color) {
      paint
        ..strokeWidth = strokeWidth
        ..color = color.withValues(alpha: 0.65);
      canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), paint);
      canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), paint);
    }

    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    cross(Offset(w * 0.12, h * 0.22), 6, 1.6, _sparkleColor);
    cross(Offset(w * 0.82, h * 0.18), 5, 1.4, _sparkleColor2);
    cross(Offset(w * 0.28, h * 0.55), 4, 1.2, _sparkleColor2);
    cross(Offset(w * 0.72, h * 0.62), 7, 1.8, _sparkleColor);

    paint
      ..strokeWidth = 1.2
      ..color = _sparkleColor.withValues(alpha: 0.35);
    canvas.drawLine(Offset(w * 0.06, h * 0.35), Offset(w * 0.09, h * 0.32), paint);
    canvas.drawLine(Offset(w * 0.90, h * 0.42), Offset(w * 0.93, h * 0.39), paint);
    canvas.drawLine(Offset(w * 0.14, h * 0.80), Offset(w * 0.17, h * 0.77), paint);
    canvas.drawLine(Offset(w * 0.84, h * 0.80), Offset(w * 0.87, h * 0.77), paint);
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) => false;
}

class _Landscape extends StatelessWidget {
  const _Landscape();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 92,
        child: CustomPaint(
          painter: _LandscapePainter(),
        ),
      ),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final back = Paint()..color = const Color(0xFF0A6A6D).withValues(alpha: 0.65);
    final mid = Paint()..color = const Color(0xFF0B4F59).withValues(alpha: 0.85);
    final front = Paint()..color = const Color(0xFF063840);

    Path hill(double y, List<double> peaks) {
      final p = Path()..moveTo(0, h);
      p.lineTo(0, y);
      for (var i = 0; i < peaks.length; i++) {
        final x = w * (i / (peaks.length - 1));
        p.lineTo(x, y - peaks[i]);
      }
      p.lineTo(w, y);
      p.lineTo(w, h);
      p.close();
      return p;
    }

    canvas.drawPath(hill(h * 0.70, [10, 18, 6, 20, 12]), back);
    canvas.drawPath(hill(h * 0.78, [6, 14, 10, 16, 8]), mid);
    canvas.drawPath(hill(h * 0.84, [4, 10, 7, 12, 5]), front);

    final bookPaint = Paint()..color = Colors.white.withValues(alpha: 0.25);
    final cx = w * 0.44;
    final cy = h * 0.58;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 44, height: 18),
      const Radius.circular(6),
    );
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-math.pi / 18);
    canvas.translate(-cx, -cy);
    canvas.drawRRect(rect, bookPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) => false;
}

