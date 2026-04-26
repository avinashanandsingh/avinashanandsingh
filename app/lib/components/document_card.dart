import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart';

class DocumentCard extends StatelessWidget {
  final String title;
  final String? url;
  final VoidCallback? onTap;
  final IconData icon;

  const DocumentCard({
    super.key,
    required this.title,
    this.onTap,
    this.url,
    this.icon = Icons.description_outlined,
  });

  Future<void> _handleTap() async {
    if (url != null) {
      final Uri uri = Uri.parse(url!);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Could not launch $url: $e');
      }
    }
    if (onTap != null) {
      onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withAlpha(
              isDark ? 100 : 20,
            ),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: isDark
              ? AppColors.cardBackgroundDark
              : AppColors.cardBackground,
          child: InkWell(
            onTap: _handleTap,
            splashColor: AppColors.primary.withAlpha(30),
            highlightColor: AppColors.primary.withAlpha(10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isDark ? AppColors.cardBackground : AppColors.primary)
                      .withAlpha(isDark ? 20 : 30),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(40),
                          AppColors.primary.withAlpha(10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      icon,
                      color: isDark ? AppColors.accentGold : AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Action Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.accentGold : AppColors.primary)
                          .withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isDark ? AppColors.accentGold : AppColors.primary,
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
}
