import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class ImageCard extends StatelessWidget {
  final String url;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final double height;
  final double borderRadius;
  final bool showGradient;
  final Widget? topTrailingAction;

  const ImageCard({
    super.key,
    required this.url,
    this.title,
    this.subtitle,
    this.onTap,
    this.height = 220,
    this.borderRadius = 24,
    this.showGradient = true,
    this.topTrailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // Base Image
              Positioned.fill(
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primary.withAlpha(20),
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                ),
              ),

              // Gradient Overlay for text readability
              if (showGradient && (title != null || subtitle != null))
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(200),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),

              // Text Overlay Content
              if (title != null || subtitle != null)
                Positioned(
                  left: 20,
                  bottom: 24,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: GoogleFonts.cinzel(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(150),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          style: GoogleFonts.lato(
                            color: Colors.white.withAlpha(220),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Optional Top Trailing Action (Glassmorphic)
              if (topTrailingAction != null)
                Positioned(top: 16, right: 16, child: topTrailingAction!),
            ],
          ),
        ),
      ),
    );
  }
}
