import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../components/layout.dart';
import '../components/invite_dialog.dart';
import '../components/home/section_header.dart';
import '../components/home/hero_card.dart';
import '../components/home/promo_banner.dart';
import '../components/home/short_courses.dart';
import '../components/home/gift_banner.dart';
import '../components/home/meditation_circles.dart';
import '../components/home/abundance_card.dart';
import '../components/home/sacred_vibes_tile.dart';
import '../components/home/superhuman_banner.dart';
import '../components/home/short_videos.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late bool isAuthenticated = false;
  @override
  void initState() {
    super.initState();
    isAuthenticated = Identity.instance.isAuthenticated;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      isAuthenticated: isAuthenticated,
      titleText: 'Hi, Raj!',
      currentIndex: 0,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton(
          onPressed: () => showInviteDialog(context),
          elevation: 8,
          shape: const CircleBorder(),
          backgroundColor: AppColors.accentGold,
          child: const Icon(Icons.share, color: AppColors.primary, size: 24),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const SectionHeader(title: "START YOUR DAY"),
            HeroCard(pulseAnimation: _pulseAnimation),
            const SizedBox(height: 16),
            const PromoBanner(
              text: "GET YOUR FREE GUIDE ON VISION BOARD",
              gradient: true,
            ),

            const SizedBox(height: 32),
            const SectionHeader(
              title: "SHORT COURSES",
              subtitle: "Bite-sized transformational journeys.",
            ),
            ShortCourses(),

            const SizedBox(height: 32),
            const GiftBanner(),

            const SizedBox(height: 32),
            const SectionHeader(
              title: "MEDITATION",
              subtitle: "Guided practices to centre your mind & energy.",
            ),
            const MeditationCircles(),

            const SizedBox(height: 36),
            const AbundanceCard(),

            const SizedBox(height: 36),
            const SectionHeader(
              title: "SACRED VIBES",
              subtitle: "Rituals, prayers and devotion to uplift your spirit.",
            ),
            const SacredVibesTile(),

            const SizedBox(height: 32),
            const SuperhumanBanner(),

            const SizedBox(height: 36),
            const SectionHeader(
              title: "SHORT VIDEOS",
              subtitle: "Snackable wisdom to keep you inspired.",
            ),
            const ShortVideos(),
            const SizedBox(height: 32),
            /* const SizedBox(height: 32),
            const InviteBanner(),

            const SizedBox(height: 48), */
          ],
        ),
      ),
    );
  }
}
