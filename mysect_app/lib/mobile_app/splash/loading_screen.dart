import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/mysect_stroke_logo_loader.dart';

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

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

    precacheImage(const AssetImage('assets/mysect_logo.png'), context);
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

              final double textProgress = ((progress - 0.70) / 0.18).clamp(
                0.0,
                1.0,
              );
              final double textOpacity = Curves.easeOut.transform(textProgress);
              final double textSlideOffset = (1.0 - textOpacity) * 8.0;

              return Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MySectStrokeLogoLoader(
                        progress: progress,
                        width: 170,
                        height: 120,
                        strokeWidth: 4.5,
                      ),
                      const SizedBox(height: 28),

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
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
