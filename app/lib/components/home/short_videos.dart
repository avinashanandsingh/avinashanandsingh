import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';

// ─── Data model ───────────────────────────────────────────────────────────────
class ShortVideoItem {
  final String title;
  final String time;
  final String img;

  const ShortVideoItem({
    required this.title,
    required this.time,
    required this.img,
  });
}

// ─── Simulated async data fetch ───────────────────────────────────────────────
Future<List<ShortVideoItem>> _fetchShortVideos() async {
  // Replace with real API call (e.g., http.get / Dio)
  await Future.delayed(const Duration(milliseconds: 800));
  return const [
    ShortVideoItem(
      title: 'BREATHWORK',
      time: '8 mins',
      img:
          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=400',
    ),
    ShortVideoItem(
      title: 'MINDSET',
      time: '5 mins',
      img:
          'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?q=80&w=400',
    ),
    ShortVideoItem(
      title: 'PRAYER',
      time: '12 mins',
      img:
          'https://images.unsplash.com/photo-1542831371-29b0f74f9713?q=80&w=400',
    ),
  ];
}

// ─── Widget ───────────────────────────────────────────────────────────────────
class ShortVideos extends StatefulWidget {
  const ShortVideos({super.key});

  @override
  State<ShortVideos> createState() => _ShortVideosState();
}

class _ShortVideosState extends State<ShortVideos> {
  late Future<List<ShortVideoItem>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _fetchShortVideos();
  }

  void _retry() {
    setState(() {
      _videosFuture = _fetchShortVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ShortVideoItem>>(
      future: _videosFuture,
      builder: (context, snapshot) {
        // ── Loading ──────────────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeleton();
        }

        // ── Error ────────────────────────────────────────────────────────────
        if (snapshot.hasError) {
          return _buildError();
        }

        // ── Data ─────────────────────────────────────────────────────────────
        final videos = snapshot.data ?? [];
        if (videos.isEmpty) return const SizedBox.shrink();

        return _buildVideoList(videos);
      },
    );
  }

  // ── Video list ──────────────────────────────────────────────────────────────
  Widget _buildVideoList(List<ShortVideoItem> videos) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return _buildVideoCard(video);
        },
      ),
    );
  }

  Widget _buildVideoCard(ShortVideoItem video) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(video.img),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withAlpha(200),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Play button
          Positioned(
            top: 12,
            right: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          // Title & duration
          Positioned(
            bottom: 12,
            left: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.accentGold,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      video.time,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Skeleton shimmer placeholder ────────────────────────────────────────────
  Widget _buildSkeleton() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (_, __) => _SkeletonCard(),
      ),
    );
  }

  // ── Error state ─────────────────────────────────────────────────────────────
  Widget _buildError() {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Failed to load videos',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                'Retry',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gradientTop,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton card ─────────────────────────────────────────────────────────
class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _shimmer = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _shimmer,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade200,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 10,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
