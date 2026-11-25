import 'package:flutter/material.dart';

class SlideTransitionRoute extends PageRouteBuilder {
  final Widget page;

  SlideTransitionRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final primaryCurve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final secondaryCurve = CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          final incomingSlide = Tween<Offset>(
            begin: const Offset(0.15, 0.0),
            end: Offset.zero,
          ).animate(primaryCurve);

          final outgoingSlide = Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.15, 0.0),
          ).animate(secondaryCurve);

          final outgoingFade = Tween<double>(
            begin: 1.0,
            end: 0.0,
          ).animate(secondaryCurve);

          return SlideTransition(
            position: outgoingSlide,
            child: FadeTransition(
              opacity: outgoingFade,
              child: SlideTransition(
                position: incomingSlide,
                child: FadeTransition(opacity: primaryCurve, child: child),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 280),
      );
}
