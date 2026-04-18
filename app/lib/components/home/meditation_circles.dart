import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';

class MeditationCircles extends StatelessWidget {
  const MeditationCircles({super.key});

  @override
  Widget build(BuildContext context) {
    final styles = [
      {
        "title": "Morning\nMiracles",
        "img":
            "https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?q=80&w=200",
      },
      {
        "title": "Night\nMiracles",
        "img":
            "https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=200",
      },
      {
        "title": "Abundance\nFlow",
        "img":
            "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?q=80&w=200",
      },
      {
        "title": "Success\nMindset",
        "img":
            "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=200",
      },
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: styles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accentGold, width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(styles[index]["img"]!),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(150),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  styles[index]["title"]!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    color: Colors.grey.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
