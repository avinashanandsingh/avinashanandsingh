import 'package:flutter/material.dart';
import '../theme/theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color primaryColor;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.primaryColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_outlined),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library),
          activeIcon: Icon(Icons.video_library_outlined),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          activeIcon: Icon(Icons.info),
          label: "",
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
