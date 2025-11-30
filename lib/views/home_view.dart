// lib/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:edunet/components/home/navbar.dart';
import 'package:edunet/components/home/hero_section.dart';
import 'package:edunet/components/home/popular_courses.dart';
import 'package:edunet/components/home/why_choose.dart';
import 'package:edunet/components/home/footer.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    print("🏠 [HOME] Building HomeView");

    return Scaffold(
      // ✅ NO AppBar - Navbar is inside the body for scrolling
      body: SafeArea(
        // ✅ Make ENTIRE page scrollable
        child: SingleChildScrollView(
          // ✅ Important for smooth scrolling on all devices
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Navbar stays at top but scrolls with content
              const Navbar(),

              // All sections stack vertically and scroll together
              const HeroSection(),
              const SizedBox(height: 48),

              const PopularCourses(),
              const SizedBox(height: 48),

              const WhyChoose(),
              const SizedBox(height: 48),

              // Footer at bottom
              const Footer(),
            ],
          ),
        ),
      ),
    );
  }
}