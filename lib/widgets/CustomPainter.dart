import 'package:flutter/material.dart';

class WaveBackground extends CustomPainter {
  final Color color1;
  final Color color2;

  WaveBackground({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color1.withOpacity(0.9),
        color2.withOpacity(0.8),
      ],
      stops: const [0.0, 1.0],
    );

    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    _drawMainWave(canvas, size, paint);

    _drawSecondaryWave(canvas, size, paint);
  }

  void _drawMainWave(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.5,
        size.width * 0.4,
        size.height * 0.7,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.9,
        size.width * 0.8,
        size.height * 0.7,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawSecondaryWave(Canvas canvas, Size size, Paint paint) {
    final secondaryPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.orange[900]!.withOpacity(0.5),
          Colors.orange[800]!.withOpacity(0.3),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.6,
        size.width * 0.5,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 1.0,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WaveBackgroundWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color color1 = Colors.orange[900]!;
    Color color2 = isDarkMode ? Colors.orange[900]! : Colors.orange[800]!;

    return CustomPaint(
      painter: WaveBackground(color1: color1, color2: color2),
      child: Container(),
    );
  }
}
