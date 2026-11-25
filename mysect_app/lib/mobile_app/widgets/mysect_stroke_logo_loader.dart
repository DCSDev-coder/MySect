import 'package:flutter/material.dart';

/// Reusable animated loader that progressively fills the new MySect logo
/// from none (0%) to half (50%) to full (100%).
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
    this.primaryBlue = const Color(0xFF062AAE),
    this.navyBlue = const Color(0xFF00B4FF),
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final fillProgress =
        Curves.easeInOut.transform((clamped / 0.85).clamp(0.0, 1.0));

    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        clipper: _HorizontalFillClipper(fillProgress),
        child: Image.asset(
          'assets/mysect_logo.png',
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _HorizontalFillClipper extends CustomClipper<Rect> {
  final double fillProgress;

  _HorizontalFillClipper(this.fillProgress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fillProgress, size.height);
  }

  @override
  bool shouldReclip(covariant _HorizontalFillClipper oldClipper) {
    return oldClipper.fillProgress != fillProgress;
  }
}

/// Self-animating repeated logo loader with no text.
class RepeatingStrokeLogoLoader extends StatefulWidget {
  final double width;
  final double height;
  final Duration cycleDuration;

  const RepeatingStrokeLogoLoader({
    super.key,
    this.width = 140,
    this.height = 95,
    this.cycleDuration = const Duration(milliseconds: 1400),
  });

  @override
  State<RepeatingStrokeLogoLoader> createState() =>
      _RepeatingStrokeLogoLoaderState();
}

class _RepeatingStrokeLogoLoaderState extends State<RepeatingStrokeLogoLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.cycleDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MySectStrokeLogoLoader(
          progress: _controller.value,
          width: widget.width,
          height: widget.height,
        );
      },
    );
  }
}
