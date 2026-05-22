import 'package:app/components/course_card.dart';
import 'package:app/components/home/branding_item.dart';
import 'package:app/components/home/section.dart';
import 'package:app/components/resource_carousel.dart';
import 'package:app/models/branding.dart';
import 'package:app/models/course.dart';
import 'package:app/models/resource.dart';
import 'package:app/models/sacredvibe.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import '../components/layout.dart';
import '../components/home/section_header.dart';
import '../components/home/hero_card.dart';
import '../components/home/short_courses.dart';
import '../components/home/meditation_circles.dart';
import '../components/home/abundance_card.dart';
import '../components/home/sacred_vibes_tile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
                    return HeroCard<BrandingItem>(
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
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            FutureBuilder(
              future: Service.resource.list(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else if (snapshot.hasData) {
                  List<ResourceData> list = snapshot.data!;
                  return ResourceCarousel(
                    items: list
                        .map(
                          (item) => ResourceCarouselItem(
                            title: item.title,
                            url: item.url,
                          ),
                        )
                        .toList(),
                  );
                } else {
                  return Container();
                }
              },
            ),

            const SizedBox(height: 8),
            FutureBuilder(
              future: Service.course.list({
                "criteria": [
                  {"column": "status", "cop": "eq", "value": "PUBLISHED"},
                  {"column": "short", "cop": "eq", "lop": "AND", "value": true},
                ],
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else if (snapshot.hasData) {
                  Result<CourseData> result = snapshot.data!;
                  if (result.succeed) {
                    return Section(
                      title: "SHORT COURSES",
                      subtitle: "Bite-sized transformational journeys.",
                      action: false,
                      child: ShortCourses(list: result.list!),
                    );
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              },
            ),

            const SizedBox(height: 32),

            FutureBuilder(
              future: Service.course.get({
                "criteria": [
                  {"column": "level", "cop": "eq", "value": "L0"},
                ],
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else if (snapshot.hasData) {
                  Result<CourseData> result = snapshot.data!;
                  if (result.succeed) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: CourseCard(
                        data: result.row!,
                        width: MediaQuery.widthOf(context).toDouble(),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }
                return Container();
              },
            ),

            //const GiftBanner(),
            const SizedBox(height: 32),
            const SectionHeader(
              title: "MEDITATION",
              subtitle: "Guided practices to centre your mind & energy.",
            ),
            const SizedBox(height: 8),
            FutureBuilder(
              future: Service.meditation.list(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return MeditationCircles(list: snapshot.data!);
                } else {
                  return Container();
                }
              },
            ),

            const SizedBox(height: 36),
            //const AbundanceCard(),
            FutureBuilder(
              future: Service.course.get({
                "criteria": [
                  {"column": "level", "cop": "eq", "value": "L1"},
                ],
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else if (snapshot.hasData) {
                  Result<CourseData> result = snapshot.data!;
                  if (result.succeed) {
                    return AbundanceCard(data: result.row!);
                  } else {
                    return Container();
                  }
                }
                return Container();
              },
            ),

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
            //const SuperhumanBanner(),
            FutureBuilder(
              future: Service.course.list({
                "criteria": [
                  {"column": "status", "cop": "eq", "value": "PUBLISHED"},
                  {
                    "column": "short",
                    "cop": "eq",
                    "lop": "AND",
                    "value": false,
                  },
                  {
                    "column": "level",
                    "cop": "ni",
                    "lop": "AND",
                    "value": ["L0", "L1"],
                  },
                ],
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else if (snapshot.hasData) {
                  Result<CourseData> result = snapshot.data!;
                  if (result.succeed) {
                    return HeroCard<CourseCard>(
                      pulseAnimation: _pulseAnimation,
                      items: [
                        for (var item in result.list!) ...[
                          CourseCard(data: item),
                        ],
                      ],
                    );
                  } else {
                    return Container();
                  }
                }
                return Container();
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
