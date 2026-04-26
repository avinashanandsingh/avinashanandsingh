import 'dart:ui';

import 'package:app/components/audio_player_dialog.dart' as AudioDialog;
import 'package:app/pages/signin.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';

class MeditationItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isLoggedIn;

  const MeditationItem({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (!isLoggedIn) {
                /*  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please log in to access this meditation.'),
                  ),
                );
                return; */
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignIn()),
                );
                return;
              }
              AudioDialog.show(
                context,
                url:
                    "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
                title: title.replaceAll("\n", " "),
                author: "Meditation",
                backgroundUrl:
                    "https://assets.mixkit.co/z8nazrerdw1dcdvnvykfp8c2yqmj",
                mode: AudioDialog.BackgroundMode.video,
              );
            },
            child: Container(
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
                    backgroundImage: NetworkImage(imageUrl),
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
                        child: Icon(
                          isLoggedIn
                              ? Icons.play_arrow_rounded
                              : Icons.lock_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextTheme.of(context).labelSmall,
          ),
        ],
      ),
    );
  }
}
