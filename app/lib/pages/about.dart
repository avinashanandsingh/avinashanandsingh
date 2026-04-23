import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../components/layout.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Layout(
      titleText: 'About Me',
      showHeader: true,
      isSerif: false,
      showBottomNav: true,
      showActions: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            RepaintBoundary(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Top Image (Now Positioned)
                  Positioned(
                    top: 0,
                    left: 16,
                    right: 16,
                    child: Container(
                      height: screenHeight * 0.45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/about_speaker.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Content Card (Now the sizing child)
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.38,
                      left: 20,
                      right: 20,
                      bottom: 40,
                    ),
                    child: Container(
                      width: screenWidth - 40,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9F2),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'ABOUT ME',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildDescriptionText(
                            'Avinash Anand Singh is a visionary coach and entrepreneur who helps leaders, entrepreneurs, and professionals connect to their inner genius to manifest extraordinary success and fulfilment.',
                          ),
                          const SizedBox(height: 16),
                          _buildDescriptionText(
                            'With an incredible ability to fuse cutting-edge insights from areas of Neuroscience, Positive Psychology, Epigenetics, and Quantum Physics with timeless, authentic Spiritual Wisdom, Avinash has guided more than 20,000 people across 9 countries to achieve rapid breakthroughs in business, leadership, health, relationships, and deep inner transformation.',
                          ),
                          const SizedBox(height: 16),
                          _buildDescriptionText(
                            'Known for his authentic presence, powerful insights, and transformational methods, Avinash works with those who seek not just achievement — but true greatness.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Social Icons & Button moved out of Stack to stabilize layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildSocialIcon(Icons.camera_alt_outlined),
                      _buildSocialIcon(Icons.play_arrow_rounded),
                      _buildSocialIcon(Icons.business_center_outlined),
                      _buildSocialIcon(Icons.facebook),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildActionButton(context),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 15,
        height: 1.6,
        color: Colors.black87.withValues(alpha: 0.7),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFF6C83E), Color(0xFFD6A054)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD6A054).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Watch TEDx Talk',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
