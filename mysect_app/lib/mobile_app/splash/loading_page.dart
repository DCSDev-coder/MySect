import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../intros/intro_1.dart';

/// Initial app open splash / loading page for MySect.
///
/// Choreographed launch animation:
/// 1. Top M-wave logo sticker unfolds onto the page from a folded-over state
///    (0% -> 44%), showing the white sticker backing peeling flat.
/// 2. Bottom "mysect" text quickly fades in with a subtle slide from the right (38% -> 58%).
/// 3. Smooth fade transition to [Intro1Page] (or [nextPage]).
class LoadingPage extends StatefulWidget {
  final VoidCallback? onLoaded;
  final Widget? nextPage;
  final Duration duration;

  const LoadingPage({
    super.key,
    this.onLoaded,
    this.nextPage,
    this.duration = const Duration(milliseconds: 1800),
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 1. M-wave logo mark: folded-over sticker slowly unfolding onto the page
  late Animation<double> _logoUnfold;
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

    _logoUnfold = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.44, curve: Curves.easeInOutCubic),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.12, curve: Curves.easeIn),
      ),
    );

    _wordmarkSlide = Tween<Offset>(
      begin: const Offset(0.08, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.58, curve: Curves.easeOutCubic),
      ),
    );
    _wordmarkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.54, curve: Curves.easeIn),
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
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
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
              // 1. Top M-wave logo mark: folded-over sticker slowly sticking on
              FadeTransition(
                opacity: _logoOpacity,
                child: _StickerFoldTransition(
                  progress: _logoUnfold,
                  child: Image.asset(
                    'assets/mysect_logo.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // 2. Bottom "mysect" text: fades and slides in from the right
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

/// Renders [child] as a sticker that starts folded over onto itself (showing
/// its white backing) and slowly unfolds from left to right as it sticks down.
class _StickerFoldTransition extends StatelessWidget {
  final Animation<double> progress;
  final Widget child;

  const _StickerFoldTransition({
    required this.progress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final double t = progress.value.clamp(0.0, 1.0);
        if (t >= 1.0) {
          return child;
        }

        // Start with a small left edge already anchored (0.12 -> 1.0) so the
        // folded-over flap sits naturally on top of the anchored side.
        final double foldFraction = 0.12 + (0.88 * t);

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 1. Stuck portion of the logo (left of the fold line)
            ClipRect(
              clipper: _HorizontalSplitClipper(
                splitFraction: foldFraction,
                keepLeft: true,
              ),
              child: child,
            ),

            // 2. Folded-over sticker backing flap (un-stuck right portion
            //    reflected horizontally across the fold line)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final double foldX = width * foldFraction;

                  // Reflect horizontally around x = foldX
                  final Matrix4 flipAroundFold = Matrix4.identity()
                    ..translateByDouble(2.0 * foldX, 0.0, 0.0, 1.0)
                    ..scaleByDouble(-1.0, 1.0, 1.0, 1.0);

                  // Soft shadow cast by the folded flap onto the stuck logo
                  final Matrix4 shadowMatrix = Matrix4.identity()
                    ..translateByDouble(
                      (2.0 * foldX) - 5.0 * (1.0 - t),
                      6.0 * (1.0 - t),
                      0.0,
                      1.0,
                    )
                    ..scaleByDouble(-1.0, 1.0, 1.0, 1.0);

                  final Widget unStuckSlice = ClipRect(
                    clipper: _HorizontalSplitClipper(
                      splitFraction: foldFraction,
                      keepLeft: false,
                    ),
                    child: child,
                  );

                  final Widget whiteBacking = ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFD8DEE8),
                          Color(0xFFFDFEFF),
                          Color(0xFFE7ECF3),
                        ],
                        stops: [0.0, 0.35, 1.0],
                      ).createShader(bounds);
                    },
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      child: unStuckSlice,
                    ),
                  );

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Soft cast shadow under the folded flap
                      Transform(
                        transform: shadowMatrix,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: 5.5,
                            sigmaY: 5.5,
                          ),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.16),
                              BlendMode.srcIn,
                            ),
                            child: unStuckSlice,
                          ),
                        ),
                      ),
                      // Curved white sticker backing flap
                      Transform(
                        transform: flipAroundFold,
                        child: whiteBacking,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HorizontalSplitClipper extends CustomClipper<Rect> {
  final double splitFraction;
  final bool keepLeft;

  _HorizontalSplitClipper({
    required this.splitFraction,
    required this.keepLeft,
  });

  @override
  Rect getClip(Size size) {
    final double splitX = (size.width * splitFraction).clamp(0.0, size.width);
    if (keepLeft) {
      return Rect.fromLTRB(0.0, 0.0, splitX, size.height);
    }
    return Rect.fromLTRB(splitX, 0.0, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant _HorizontalSplitClipper oldClipper) {
    return oldClipper.splitFraction != splitFraction ||
        oldClipper.keepLeft != keepLeft;
  }
}
