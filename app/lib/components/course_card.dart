import 'package:app/models/course.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../pages/course_details.dart';

class CourseCard extends StatelessWidget {
  final CourseData data;

  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const CourseCard({
    super.key,
    required this.data,
    this.onTap,
    this.width = 150,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            /* Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CourseDetails()),
            ); */
          },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(data.thumbnail!),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Gradient overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withAlpha(220),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Title & CTA in Foreground
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.title!,
                    style: GoogleFonts.cinzel(
                      color: Colors.amberAccent,
                      fontSize: 24,
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
      ),
    );
  }
}
