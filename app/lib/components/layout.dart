import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/header.dart';
import '../theme/theme.dart';

class Layout extends StatefulWidget {
  final Widget body;
  final String titleText;
  final int currentIndex;
  final bool showHeader;
  final bool showBottomNav;
  final bool isSerif;
  final bool showProfileActions;
  final bool isAuthenticated;
  final PreferredSizeWidget? appBarBottom;
  final Widget? floatingActionButton;

  const Layout({
    super.key,
    required this.body,
    this.titleText = 'Dashboard',
    this.currentIndex = 0,
    this.showHeader = true,
    this.showBottomNav = true,
    this.isSerif = false,
    this.showProfileActions = true,
    this.isAuthenticated = true,
    this.appBarBottom,
    this.floatingActionButton,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  void _onNavTap(int index) {
    if (index == widget.currentIndex) return;
    switch (index) {
      case 0:
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed("/home");
        break;
      case 1:
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed("/dashboard");
        break;
      case 2:
        /* showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const CreateCommunityBottomSheet(),
        ); */
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showHeader
          ? Header(
              titleText: widget.titleText,
              isSerif: widget.isSerif,
              showProfileActions: widget.showProfileActions,
              isAuthenticated: widget.isAuthenticated,
              bottom: widget.appBarBottom,
              leading: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(0),
                  shape: BoxShape.circle,
                ),
                child: Image(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.contain,
                ),
                //Icon(Icons.blur_on, color: AppColors.primary, size: 24),
              ),
            )
          : null,
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.showBottomNav
          ? BottomNav(currentIndex: widget.currentIndex, onTap: _onNavTap)
          : null,
    );
  }
}
