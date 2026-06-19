import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';

class StripItem {
  final String label;
  final IconData icon;
  final String id;

  const StripItem({required this.label, required this.icon, required this.id});
}

class ButtonStrip extends StatelessWidget {
  final String activeId;
  final ValueChanged<String> onTabSelected;

  const ButtonStrip({
    super.key,
    required this.activeId,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<StripItem> items = [
      const StripItem(
        id: 'overview',
        label: 'Overview',
        icon: Icons.info_outline,
      ),
      const StripItem(
        id: 'curriculum',
        label: 'Curriculum',
        icon: Icons.menu_book,
      ),
      const StripItem(
        id: 'certificate',
        label: 'Certificate',
        icon: Icons.card_membership,
      ),
      const StripItem(id: 'review', label: 'Review', icon: Icons.rate_review),
    ];

    return Container(
      // The baseline track across the bottom of the entire strip
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          // IntrinsicHeight forces the Row and vertical dividers to expand properly
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final bool isActive = item.id == activeId;

              // Determine if we should show a divider after this item
              // Don't show it if it's the last item, or if it/the next item is active
              final bool showDivider =
                  index < items.length - 1 &&
                  !isActive &&
                  items[index + 1].id != activeId;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. The Button with Underline Border
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isActive ? Colors.purple : Colors.transparent,
                          width: 2.0, // Highlight thickness
                        ),
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: () => onTabSelected(item.id),
                      icon: Icon(
                        item.icon,
                        size: 18,
                        color: isActive ? AppColors.primary : AppColors.primary,
                      ),
                      label: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.purple.shade100,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 14.0,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. The Vertical Divider
                  if (showDivider)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                      ), // Shrinks the height slightly
                      child: VerticalDivider(
                        color: Colors.grey,
                        thickness: 1.0,
                        width: 1.0, // Space the divider itself takes up
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
