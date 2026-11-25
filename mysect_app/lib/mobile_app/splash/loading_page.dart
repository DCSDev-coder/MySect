import 'package:flutter/material.dart';
import '../intros/intro_1.dart';

/// Initial app open splash / loading page for MySect.
///
/// Choreographed launch animation using [assets/mysect_main_logo.png]:
/// 1. Top M-wave logo mark bounces into place (0% -> 50%).
/// 2. Bottom "mysect" text slides in from the right (45% -> 80%).
/// 3. Smooth fade transition to [Intro1Page] (or [nextPage]).
class LoadingPage extends StatefulWidget {
  final VoidCallback? onLoaded;
  final Widget? nextPage;
  final Duration duration;

  const LoadingPage({
    super.key,
    this.onLoaded,
    this.nextPage,
    this.duration = const Duration(milliseconds: 2800),
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 1. M-wave logo mark: bounce drop + scale
  late Animation<Offset> _logoBounce;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // 2. "mysect" text: slide in from right + fade
  late Animation<Offset> _wordmarkSlide;
  late Animation<double> _wordmarkOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _logoBounce = Tween<Offset>(
      begin: const Offset(0.0, -0.65),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.50, curve: Curves.bounceOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.bounceOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.20, curve: Curves.easeIn),
      ),
    );

    _wordmarkSlide = Tween<Offset>(
      begin: const Offset(0.35, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.80, curve: Curves.easeOutCubic),
      ),
    );
    _wordmarkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.68, curve: Curves.easeIn),
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

    precacheImage(const AssetImage('assets/mysect_logo.png'), context);
    precacheImage(const AssetImage('assets/sect.png'), context);
    precacheImage(const AssetImage('assets/incorporation.webp'), context);
    precacheImage(const AssetImage('assets/nextbutton.webp'), context);
  }

  @override
  Widget build(BuildContext context) {
    const double logoWidth = 185;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Top M-wave logo mark: bounces into place
              SlideTransition(
                position: _logoBounce,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset(
                      'assets/mysect_logo.png',
                      width: logoWidth,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // 2. Bottom "mysect" text: slides in from the right, tight under logo
              SlideTransition(
                position: _wordmarkSlide,
                child: FadeTransition(
                  opacity: _wordmarkOpacity,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.center,
                      heightFactor: 0.42,
                      child: Image.asset(
                        'assets/sect.png',
                        width: logoWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
