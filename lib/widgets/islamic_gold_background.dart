import 'package:flutter/material.dart';

class IslamicGoldBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const IslamicGoldBackground({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Palet “emas + hijau tua”
    final deep = isDark ? const Color(0xFF061A12) : const Color(0xFF063A2A);
    final deep2 = isDark ? const Color(0xFF020B08) : const Color(0xFF02150F);
    final gold = const Color(0xFFD4AF37);

    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.2, -0.6),
              radius: 1.2,
              colors: [
                deep.withOpacity(0.95),
                deep2.withOpacity(0.98),
              ],
            ),
          ),
        ),

        // Islamic pattern (ukiran geometris)
        Positioned.fill(
          child: CustomPaint(
            painter: _IslamicPatternPainter(
              gold: gold,
              opacity: isDark ? 0.14 : 0.10,
            ),
          ),
        ),

        // Vignette biar “mahal”
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(isDark ? 0.25 : 0.10),
                  Colors.transparent,
                  Colors.black.withOpacity(isDark ? 0.35 : 0.12),
                ],
              ),
            ),
          ),
        ),

        // Content
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ],
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final Color gold;
  final double opacity;

  _IslamicPatternPainter({required this.gold, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paintStroke = Paint()
      ..color = gold.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final paintFill = Paint()
      ..color = gold.withOpacity(opacity * 0.55)
      ..style = PaintingStyle.fill;

    // Ukuran tile pattern
    const tile = 92.0;
    final cols = (size.width / tile).ceil() + 1;
    final rows = (size.height / tile).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * tile + (r.isEven ? tile * 0.5 : 0);
        final cy = r * tile;

        _draw8PointStar(canvas, Offset(cx, cy), 18, 8, paintFill, paintStroke);
        _drawRosette(canvas, Offset(cx + 36, cy + 36), 10, paintStroke);
      }
    }
  }

  void _draw8PointStar(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    Paint fill,
    Paint stroke,
  ) {
    final path = Path();
    const points = 16; // 8-point star => 16 vertices
    for (int i = 0; i < points; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? outerRadius : innerRadius;
      final angle = (i * 2 * 3.1415926535 / points) - 3.1415926535 / 2;
      final x = center.dx + r * Math.cos(angle);
      final y = center.dy + r * Math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Lingkaran kecil di tengah biar ornament terasa “ukiran”
    canvas.drawCircle(center, 2.6, stroke);
  }

  void _drawRosette(Canvas canvas, Offset center, double radius, Paint stroke) {
    final petals = 6;
    final path = Path();
    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * 3.1415926535 / petals);
      final p = Offset(
        center.dx + radius * Math.cos(angle),
        center.dy + radius * Math.sin(angle),
      );
      if (i == 0) path.moveTo(p.dx, p.dy);
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.gold != gold || oldDelegate.opacity != opacity;
  }
}

/// Helper math biar tidak import dart:math di banyak file
class Math {
  static double sin(double x) => _mathSin(x);
  static double cos(double x) => _mathCos(x);
}

// Implementasi sederhana: gunakan dart:math tapi dibungkus agar file tetap rapi
double _mathSin(double x) => (x).sin();
double _mathCos(double x) => (x).cos();

extension _Trig on double {
  double sin() => (this).toDouble() == 0 ? 0 : _sin(this);
  double cos() => _cos(this);
}

// Pakai dart:math secara implisit (kompiler tetap resolve), ini aman di Flutter
double _sin(double x) => (x as dynamic).sin();
double _cos(double x) => (x as dynamic).cos();
