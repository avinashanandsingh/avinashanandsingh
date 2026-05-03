import 'dart:async';
import 'package:app/components/home/branding_item.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class HeroCard extends StatefulWidget {
  final Animation<double> pulseAnimation;
  final List<BrandingItem> items;
  const HeroCard({
    super.key,
    required this.items,
    required this.pulseAnimation,
  });

  @override
  State<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<HeroCard> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  int len = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
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

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Listener(
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                    }

                    return Center(
                      child: SizedBox(
                        height: Curves.easeOut.transform(value) * 220,
                        width:
                            Curves.easeOut.transform(value) *
                            MediaQuery.of(context).size.width,
                        child: child,
                      ),
                    );
                  },
                  child: BrandingItem(
                    type: widget.items[index].type,
                    title: widget.items[index].title,
                    content: widget.items[index].content,
                    url: widget.items[index].url,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primary
                    : AppColors.primary.withAlpha(50),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
