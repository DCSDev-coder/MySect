import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../authentication/login_page.dart';
import 'intro_2.dart';
import '../authentication/slide_transition_route.dart';
import '../widgets/app_top_header.dart';

class Intro1Page extends StatelessWidget {
  const Intro1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      AppTopHeader(
                        showNotificationBell: false,
                        trailing: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              SlideTransitionRoute(page: const LoginPage()),
                              (route) => false,
                            );
                          },
                          child: Text(
                            'Skip',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: double.infinity),
                              Image.asset('assets/incorporation.png', height: 200),
                              const SizedBox(height: 20),
                              Text(
                                'Incorporation and\nCompany Secretary',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Get our help to meet tax compliance requirements and\nsave your business from devasting tax issue',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(SlideTransitionRoute(page: const Intro2Page()));
                                },
                                child: Image.asset('assets/nextbutton.png', height: 70),
                              ),
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
