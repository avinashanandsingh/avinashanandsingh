import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool? action;
  final void Function()? onAction;
  final Widget child;

  const Section({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 15, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.accentGold,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.displayMedium),
                ],
              ),
              if (action != null) ...[
                Row(
                  children: [
                    TextButton.icon(
                      label: Text(
                        "Explore",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      onPressed: onAction,
                      iconAlignment: IconAlignment.end,
                      icon: Icon(Icons.chevron_right, size: 24),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (subtitle != null) ...[
          Padding(
            padding: EdgeInsets.only(left: 15, right: 10),
            child: Row(
              children: [
                Text(subtitle!, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ],
        child,
      ],
    );
  }
}
