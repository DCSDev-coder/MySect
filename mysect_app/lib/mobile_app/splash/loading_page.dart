import 'package:flutter/material.dart';
import '../intros/intro_1.dart';

/// Initial app open splash / loading page for MySect.
///
/// Features a choreographed 3-image brand assembly animation:
/// 1. [assets/y.png] pops in first with its own scale and fade animation.
/// 2. [assets/sect.png] slides in next from the right with its own slide animation.
/// 3. [assets/your_secretary_company.png] slides in next underneath with its own animation.
/// 4. Seamless transition to [Intro1Page] (or [nextPage]).
class LoadingPage extends StatefulWidget {
  final VoidCallback? onLoaded;
  final Widget? nextPage;
  final Duration duration;

  const LoadingPage({
    super.key,
    this.onLoaded,
    this.nextPage,
    this.duration = const Duration(milliseconds: 3200),
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 1. Animation for Image 1: y.png (The Mark)
  late Animation<double> _yScale;
  late Animation<double> _yOpacity;

  // 2. Animation for Image 2: sect.png ("Sect")
  late Animation<Offset> _sectSlide;
  late Animation<double> _sectOpacity;

  // 3. Animation for Image 3: your_secretary_company.png (The Tagline)
  late Animation<Offset> _taglineSlide;
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // 1. y.png: Scale & fade in (0% -> 32%)
    _yScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.32, curve: Curves.easeOutBack),
      ),
    );
    _yOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    // 2. sect.png: Slides in from the right (32% -> 60%)
    _sectSlide = Tween<Offset>(
      begin: const Offset(0.45, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.60, curve: Curves.easeOutCubic),
      ),
    );
    _sectOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.52, curve: Curves.easeIn),
      ),
    );

    // 3. your_secretary_company.png: Slides up from underneath (58% -> 84%)
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.84, curve: Curves.easeOutCubic),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.78, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onLoaded != null) {
          widget.onLoaded!.call();
        } else if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  widget.nextPage ?? const Intro1Page(),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
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

    precacheImage(const AssetImage('assets/y.png'), context);
    precacheImage(const AssetImage('assets/sect.png'), context);
    precacheImage(const AssetImage('assets/your_secretary_company.png'), context);
    precacheImage(const AssetImage('assets/mysect_logo.webp'), context);
    precacheImage(const AssetImage('assets/incorporation.webp'), context);
    precacheImage(const AssetImage('assets/nextbutton.webp'), context);
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
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row: [Image 1: y.png] + [Image 2: sect.png]
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 1. y.png with scale & fade animation
                      FadeTransition(
                        opacity: _yOpacity,
                        child: ScaleTransition(
                          scale: _yScale,
                          child: Image.asset(
                            'assets/y.png',
                            height: 57,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),

                      // 2. sect.png with slide from right & fade animation
                      SlideTransition(
                        position: _sectSlide,
                        child: FadeTransition(
                          opacity: _sectOpacity,
                          child: Image.asset(
                            'assets/sect.png',
                            height: 72,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 3. your_secretary_company.png with slide from below & fade animation
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: Image.asset(
                        'assets/your_secretary_company.png',
                        width: 215,
                        fit: BoxFit.contain,
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
