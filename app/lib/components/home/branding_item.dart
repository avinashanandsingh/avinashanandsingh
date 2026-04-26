import 'package:app/components/document_card.dart';
import 'package:app/components/image_card.dart';
import 'package:app/components/text_card.dart';
import 'package:app/components/video_card.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';

class BrandingItem extends StatelessWidget {
  final String type;
  final String title;
  final String? content;
  final String? url;
  final bool? isLoggedIn;

  const BrandingItem({
    super.key,
    required this.type,
    required this.title,
    this.content,
    this.url,
    this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      "TEXT" => TextCard(
        title: title,
        content: content!,
        //icon: Icons.lightbulb_outline,
        accentColor: AppColors.accentGold,
      ),
      "DOCUMENT" => DocumentCard(title: title, url: url!),
      "IMAGE" => ImageCard(title: title, url: url!),
      "VIDEO" => VideoCard(title: title, url: url!),
      _ => Container(),
    };
  }
}
