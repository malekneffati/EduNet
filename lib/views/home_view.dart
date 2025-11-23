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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Navbar(),
            const HeroSection(),
            const PopularCourses(),
            const WhyChoose(),
            const Footer(),
          ],
        ),
      ),
    );
  }
}