import 'package:app/models/course.dart';
import 'package:app/pages/course/public.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../pages/course_details.dart';

class ShortCourses extends StatelessWidget {
  final List<CourseData> list;
  const ShortCourses({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PublicCourse(data: list[index]),
                ),
              );
            },
            child: Container(
              width: 150,
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
                  image: NetworkImage(list[index].thumbnail!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
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
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list[index].title!,
                          style: GoogleFonts.cinzel(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "Buy Now",
                              style: GoogleFonts.montserrat(
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
        },
      ),
    );
  }
}
