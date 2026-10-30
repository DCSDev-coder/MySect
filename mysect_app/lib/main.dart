import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mobile_app/intros/intro_1.dart';
import 'mobile_app/splash/loading_page.dart';

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
      home: const LoadingPage(
        nextPage: Intro1Page(),
      ),
    );
  }
}
