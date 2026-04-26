import 'dart:ui';
import 'package:app/components/audio_player_dialog.dart' as AudioDialog;
import 'package:app/components/home/meditation_item.dart';
import 'package:app/services/identity.dart';
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
      child: FutureBuilder(
        future: Identity().isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: styles.length,
              itemBuilder: (context, index) {
                return MeditationItem(
                  title: styles[index]["title"]!,
                  imageUrl: styles[index]["img"]!,
                  isLoggedIn: snapshot.data!,
                );
              },
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
