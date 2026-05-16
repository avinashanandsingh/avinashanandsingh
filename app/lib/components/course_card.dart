import 'package:app/models/course.dart';
import 'package:app/pages/course/private.dart';
import 'package:app/pages/course/public.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import 'package:app/helpers/globals.dart';

class CourseCard extends StatelessWidget {
  final CourseData data;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final double? aspectRatio;

  const CourseCard({
    super.key,
    required this.data,
    this.onTap,
    this.width = 150,
    this.height,
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(data.thumbnail ?? ''),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title ?? '',
                  style: GoogleFonts.cinzel(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Play Now',
                      style: GoogleFonts.lato(
                        color: AppColors.accentGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppColors.accentGold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (aspectRatio != null && height == null) {
      cardContent = AspectRatio(aspectRatio: aspectRatio!, child: cardContent);
    }

    return GestureDetector(
      onTap:
          onTap ??
          () async {
            bool flag = await Service.identity.isLoggedIn();
            if (flag) {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => PrivateCourse(data: data),
                ),
              );
            } else {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => PublicCourse(data: data),
                ),
              );
            }
          },
      child: cardContent,
    );
  }
}
