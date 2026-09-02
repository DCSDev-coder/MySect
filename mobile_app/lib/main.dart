import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mobile_app/intros/intro_1.dart';
import 'mobile_app/splash/loading_screen.dart';
import 'mobile_app/authentication/slide_transition_route.dart';

void main() {
  runApp(const MySectApp());
}

class MySectApp extends StatelessWidget {
  const MySectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySect App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF062AAE)),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => MySectStrokeLoadingScreen(
          onLoaded: () {
            Navigator.of(context).pushReplacement(
              SlideTransitionRoute(page: const Intro1Page()),
            );
          },
        ),
      ),
    );
  }
}
