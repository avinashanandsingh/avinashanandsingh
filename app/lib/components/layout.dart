import 'package:app/components/error_overlay.dart';
import 'package:app/components/invite_dialog.dart';
import 'package:app/pages/reels_player.dart';
import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/header.dart';
import '../theme/theme.dart';

class Layout extends StatefulWidget {
  final Widget body;
  final String titleText;
  final int currentIndex;
  final bool showHeader;
  final bool showBack;
  final bool showBottomNav;
  final bool isSerif;
  final bool showActions;
  final PreferredSizeWidget? appBarBottom;

  const Layout({
    super.key,
    required this.body,
    this.titleText = 'Dashboard',
    this.currentIndex = 0,
    this.showHeader = true,
    this.showBack = false,
    this.showBottomNav = true,
    this.isSerif = false,
    this.showActions = true,
    this.appBarBottom,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  late bool isAuthenticated = false;

  Widget? get loading => null;

  @override
  void initState() {
    super.initState();
    isAuthenticated = Identity.instance.isAuthenticated;
  }

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReelsPlayer(
              reels: [
                Reel(
                  url: "https://youtu.be/l8Ymo-PGs64",
                  title: "My Awesome Short",
                  description: "This is a great description for a reel.",
                  likes: 1200,
                ),
                Reel(
                  url: "https://vimeo.com/524933864",
                  title: "Vimeo Showcase",
                  description: "Vimeo shorts are also supported!",
                  likes: 350,
                ),
                Reel(
                  url:
                      "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
                  title: "Standard Video",
                  description: "Playing standard MP4 videos from a server.",
                  likes: 99,
                ),
              ],
            ),
          ),
        );
        break;
      case 2:
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed("/dashboard");
        break;
      case 3:
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed("/about");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.showHeader
            ? Header(
                titleText: widget.titleText,
                isSerif: widget.isSerif,
                showActions: widget.showActions,
                isAuthenticated: isAuthenticated,
                bottom: widget.appBarBottom,

                leading: Row(
                  children: [
                    if (widget.showBack) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 16,
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushReplacementNamed("/home");
                        },
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.only(
                          left: 8,
                          top: 8,
                          bottom: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(0),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ],
                  ],
                ),
              )
            : null,
        body: widget.body,
        floatingActionButton: FutureBuilder<bool>(
          future: Identity.instance.isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 3. Show placeholder while loading
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data!) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: FloatingActionButton(
                    onPressed: () => InviteDialog.show(context),
                    elevation: 8,
                    shape: const CircleBorder(),
                    backgroundColor: AppColors.accentGold,
                    child: const Icon(
                      Icons.share,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                );
              } else {
                return Container();
              }
            } else {
              return Container();
            }
          },
        ),
        bottomNavigationBar: widget.showBottomNav
            ? BottomNav(currentIndex: widget.currentIndex, onTap: _onNavTap)
            : null,
      ),
    );
  }

  Widget onError(Object? object) {
    return ErrorOverlay(message: object!.toString(), title: 'Error');
  }
}
