import 'package:app/components/home/branding_item.dart';
import 'package:app/components/home/section.dart';
import 'package:app/models/branding.dart';
import 'package:app/models/course.dart';
import 'package:app/models/filter.dart';
import 'package:app/models/sacredvibe.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';
import '../components/layout.dart';
import '../components/home/section_header.dart';
import '../components/home/hero_card.dart';
//import '../components/home/branding_banner.dart';
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
  late Filter filterShortCourse = Filter();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    List<Criteria> criteria = [];
    criteria.add(Criteria(column: "short", cop: "eq", value: true));
    filterShortCourse.criteria = criteria;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      titleText: 'Welcome Back!',
      currentIndex: 0,
      isSerif: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            //const SectionHeader(title: "START YOUR DAY"),
            Section(
              title: "START YOUR DAY",
              child: FutureBuilder(
                future: Service.branding.list(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    List<BrandingData> list = snapshot.data!;
                    return HeroCard(
                      pulseAnimation: _pulseAnimation,
                      items: list
                          .map(
                            (item) => BrandingItem(
                              type: item.type,
                              title: item.title,
                              content: item.content,
                              url: item.url,
                            ),
                          )
                          .toList(),
                    );
                  }
                  return Container();
                },
              ),
            ),

            //const SizedBox(height: 16),
            //const BrandingBanner(),
            const SizedBox(height: 32),
            Section(
              title: "SHORT COURSES",
              subtitle: "Bite-sized transformational journeys.",
              action: true,
              onAction: () {
                print("Load...");
              },
              child: FutureBuilder(
                future: Service.course.list(true),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return ShortCourses(list: snapshot.data!);
                  }
                  return Container();
                },
              ),
            ),

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
            Section(
              title: "SACRED VIBES",
              subtitle: "Rituals, prayers and devotion to uplift your spirit.",
              child: FutureBuilder(
                future: Service.sacredvibe.list(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    List<SacredvibeData> list = snapshot.data!;

                    return SacredVibesTile(items: list);
                  }
                  return Container();
                },
              ),
            ),

            const SizedBox(height: 32),
            const SuperhumanBanner(),

            const SizedBox(height: 36),
            const SectionHeader(
              title: "SHORT VIDEOS",
              subtitle: "Snackable wisdom to keep you inspired.",
            ),
            const ShortVideos(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
