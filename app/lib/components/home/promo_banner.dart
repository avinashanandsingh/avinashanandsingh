import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';

class PromoBanner extends StatelessWidget {
  final String text;
  final bool gradient;

  const PromoBanner({super.key, required this.text, this.gradient = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient
            ? LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(30),
                  AppColors.accentGold.withAlpha(40),
                ],
              )
            : null,
        color: !gradient ? AppColors.accentGold.withAlpha(20) : null,
        border: Border.all(
          color: gradient
              ? AppColors.accentGold.withAlpha(80)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accentGold, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.lato(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
