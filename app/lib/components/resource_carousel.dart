import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart';

class ResourceCarouselItem {
  final String title;
  final String url;

  ResourceCarouselItem({required this.title, required this.url});
}

class ResourceCarousel extends StatefulWidget {
  final List<ResourceCarouselItem> items;
  final bool autoScroll;
  final Duration autoScrollInterval;

  const ResourceCarousel({
    super.key,
    required this.items,
    this.autoScroll = true,
    this.autoScrollInterval = const Duration(seconds: 5),
  });

  @override
  State<ResourceCarousel> createState() => _ResourceCarouselState();
}

class _ResourceCarouselState extends State<ResourceCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    if (widget.autoScroll) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(widget.autoScrollInterval, (timer) {
      if (_pageController.hasClients && widget.items.isNotEmpty) {
        if (_currentPage < widget.items.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleDownload(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.12)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: Transform.scale(
                      scale: Curves.easeOut.transform(value),
                      child: child,
                    ),
                  );
                },
                child: _buildResourceCard(item),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildResourceCard(ResourceCarouselItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withAlpha(
              isDark ? 80 : 30,
            ),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          child: InkWell(
            onTap: () {
              _stopAutoScroll();
              _handleDownload(item.url);
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withAlpha(200)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Stack(
                children: [
                  // Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.download_for_offline_rounded,
                            color: Colors.white.withAlpha(180),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Tap to download",
                            style: GoogleFonts.inter(
                              color: Colors.white.withAlpha(160),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Arrow
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    top: 0,
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white24,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: _currentPage == index ? 18 : 6,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.primary
                : AppColors.primary.withAlpha(60),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
