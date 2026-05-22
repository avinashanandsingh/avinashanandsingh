import 'package:app/components/error_overlay.dart';
import 'package:app/components/invite_dialog.dart';
import 'package:app/models/short.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/about.dart';
import 'package:app/pages/dashboard.dart';
import 'package:app/pages/home.dart';
import 'package:app/pages/reels_player.dart';
import 'package:app/pages/user/signin.dart';
import 'package:app/services/identity.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/alert.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/header.dart';
import '../theme/theme.dart';
import '../helpers/globals.dart';

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

  void _onNavTap(int index) async {
    if (index == widget.currentIndex) return;
    switch (index) {
      case 0:
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const Home()),
        );
        break;
      case 1:
        Result<ShortData> result = await Service.short.list();
        if (result.succeed) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => ReelsPlayer(reels: result.list!),
            ),
          );
        } else {
          Alert.show(result.message!, isError: true);
        }

        break;
      case 2:
        bool flag = await Service.identity.isLoggedIn();
        if (flag) {
          UserData? user = await Service.identity.me();
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => Dashboard(user: user!)),
          );
        } else {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => SignIn()),
          );
        }
        break;
      case 3:
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => About()),
        );
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
                          size: 20,
                        ),
                        onPressed: () {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(builder: (context) => Home()),
                          );
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
