import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fullscreen 5-Second Loading Screen
class MySectStrokeLoadingScreen extends StatefulWidget {
  final VoidCallback? onLoaded;

  const MySectStrokeLoadingScreen({super.key, this.onLoaded});

  @override
  State<MySectStrokeLoadingScreen> createState() =>
      _MySectStrokeLoadingScreenState();
}

class _MySectStrokeLoadingScreenState extends State<MySectStrokeLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 5 seconds total duration, plays once without looping
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Trigger onLoaded callback when the animation finishes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onLoaded?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache Intro 1 images so they appear instantly when the transition happens
    precacheImage(const AssetImage('assets/YourSectComp.png'), context);
    precacheImage(const AssetImage('assets/incorporation.png'), context);
    precacheImage(const AssetImage('assets/nextbutton.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double progress = _controller.value;

              // Subtitle fade-in and slight upward slide between 3.5s and 4.4s (progress 0.70 -> 0.88)
              final double textProgress = ((progress - 0.70) / 0.18).clamp(0.0, 1.0);
              final double textOpacity = Curves.easeOut.transform(textProgress);
              final double textSlideOffset = (1.0 - textOpacity) * 8.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo Widget
                  MySectStrokeLogoLoader(
                    progress: progress,
                    width: 170,
                    height: 120,
                    strokeWidth: 4.5,
                  ),
                  const SizedBox(height: 28),

                  // "Your Company Secretary" Subtitle
                  Opacity(
                    opacity: textOpacity,
                    child: Transform.translate(
                      offset: Offset(0, textSlideOffset),
                      child: Text(
                        "YOUR COMPANY SECRETARY",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF101144),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Standalone Animated Logo Widget
class MySectStrokeLogoLoader extends StatelessWidget {
  final double progress;
  final double width;
  final double height;
  final double strokeWidth;
  final Color primaryBlue;
  final Color navyBlue;

  const MySectStrokeLogoLoader({
    super.key,
    required this.progress,
    this.width = 170,
    this.height = 120,
    this.strokeWidth = 4.5,
    this.primaryBlue = const Color(0xFF1A74BA),
    this.navyBlue = const Color(0xFF101144),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _MySectStrokePainter(
        progress: progress,
        strokeWidth: strokeWidth,
        primaryBlue: primaryBlue,
        navyBlue: navyBlue,
      ),
    );
  }
}

/// CustomPainter for progressive stroke outline & fill reveal
class _MySectStrokePainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color primaryBlue;
  final Color navyBlue;

  _MySectStrokePainter({
    required this.progress,
    required this.strokeWidth,
    required this.primaryBlue,
    required this.navyBlue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double refWidth = 200.0;
    const double refHeight = 130.0;
    final double scale = math.min(size.width / refWidth, size.height / refHeight);

    canvas.save();
    canvas.translate(
      (size.width - refWidth * scale) / 2,
      (size.height - refHeight * scale) / 2,
    );
    canvas.scale(scale);

    const double slantAngle = -0.394; // ~22.6° slant matching logo
    const double barWidth = 32.0;

    // Timeline phases:
    // 0.0s -> 3.5s (0.00 -> 0.70): Progressive line drawing
    // 3.5s -> 4.5s (0.70 -> 0.90): Solid color fill reveal
    // 4.5s -> 5.0s (0.90 -> 1.00): Fully revealed hold state
    double drawProgress;
    double fillOpacity = 0.0;

    if (progress <= 0.70) {
      drawProgress = Curves.easeInOutCubic.transform(progress / 0.70);
      fillOpacity = 0.0;
    } else if (progress <= 0.90) {
      drawProgress = 1.0;
      fillOpacity = Curves.easeIn.transform((progress - 0.70) / 0.20);
    } else {
      drawProgress = 1.0;
      fillOpacity = 1.0;
    }

    // 1. LEFT BAR (Short Cyan/Blue)
    _drawCapsuleStroke(
      canvas: canvas,
      center: const Offset(36, 96),
      length: 46.0,
      width: barWidth,
      angle: slantAngle,
      color: primaryBlue,
      drawProgress: (drawProgress * 1.3).clamp(0.0, 1.0),
      fillOpacity: fillOpacity,
    );

    // 2. CENTER BAR (Tall Navy)
    _drawCapsuleStroke(
      canvas: canvas,
      center: const Offset(92, 65),
      length: 112.0,
      width: barWidth,
      angle: slantAngle,
      color: navyBlue,
      drawProgress: ((drawProgress - 0.15) * 1.4).clamp(0.0, 1.0),
      fillOpacity: fillOpacity,
    );

    // 3. RIGHT BAR (Tall Cyan/Blue)
    _drawCapsuleStroke(
      canvas: canvas,
      center: const Offset(154, 65),
      length: 112.0,
      width: barWidth,
      angle: slantAngle,
      color: primaryBlue,
      drawProgress: ((drawProgress - 0.30) * 1.5).clamp(0.0, 1.0),
      fillOpacity: fillOpacity,
    );

    canvas.restore();
  }

  void _drawCapsuleStroke({
    required Canvas canvas,
    required Offset center,
    required double length,
    required double width,
    required double angle,
    required Color color,
    required double drawProgress,
    required double fillOpacity,
  }) {
    if (drawProgress <= 0.0) return;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: length,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(width / 2),
    );

    // Fill reveal
    if (fillOpacity > 0.0) {
      final fillPaint = Paint()
        ..color = color.withAlpha((fillOpacity * 255).round())
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);
    }

    // Stroke outline path
    final Path fullPath = Path()..addRRect(rrect);
    final Path strokePath = Path();

    for (final PathMetric metric in fullPath.computeMetrics()) {
      final double extractLength = metric.length * drawProgress;
      strokePath.addPath(
        metric.extractPath(0.0, extractLength),
        Offset.zero,
      );
    }

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawPath(strokePath, strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MySectStrokePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.primaryBlue != primaryBlue ||
        oldDelegate.navyBlue != navyBlue;
  }
}
