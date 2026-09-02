import 'package:flutter/material.dart';
import 'mobile_app/intros/landing_page.dart';

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
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}
