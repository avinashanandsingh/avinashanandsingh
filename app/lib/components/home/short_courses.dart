import 'package:app/models/course.dart';
import 'package:app/pages/course/private.dart';
import 'package:app/pages/course/public.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'package:app/helpers/globals.dart';

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
          return SmallCard(
            imageUrl: list[index].thumbnail!,
            title: list[index].title!,
            //subtitle: 'Buy Now',
            imageHeight: 130,
            width: 130,
            onTap: () async {
              bool flag = await Service.identity.isLoggedIn();
              if (flag) {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => PrivateCourse(data: list[index]),
                  ),
                );
              } else {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => PublicCourse(data: list[index]),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class SmallCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final double? width;
  final double imageHeight;
  final double borderRadius;

  const SmallCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
    this.width,
    this.imageHeight = 135,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFFF3E5F5), // Light purple/lavender
              Color(0xFFFFFDE7), // Very light yellow
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius),
              ),
              child: Image.network(
                imageUrl,
                height: imageHeight,
                width: width,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: imageHeight,
                  width: width,
                  color: Colors.grey.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),

            // Text Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
