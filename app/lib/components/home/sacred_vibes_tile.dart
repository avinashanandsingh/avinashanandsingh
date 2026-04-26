import 'dart:async';
import 'package:app/models/sacredvibe.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../audio_player_dialog.dart' as audio_dialog;

class SacredVibesTile extends StatefulWidget {
  final List<SacredvibeData> items;
  const SacredVibesTile({super.key, required this.items});

  @override
  State<SacredVibesTile> createState() => _SacredVibesTileState();
}

class _SacredVibesTileState extends State<SacredVibesTile> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < widget.items.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return _buildVibeCard(widget.items[index]);
        },
      ),
    );
  }

  Widget _buildVibeCard(SacredvibeData vibe) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => audio_dialog.show(
            context,
            url: vibe.url,
            title: vibe.title,
            //author: "Sacred Vibes",
            mode: audio_dialog.BackgroundMode.animation,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.nightlight_round,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(vibe.title, style: TextTheme.of(context).titleSmall),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        vibe.duration,
                        style: GoogleFonts.montserrat(
                          color: AppColors.accentGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.play_circle_fill,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
