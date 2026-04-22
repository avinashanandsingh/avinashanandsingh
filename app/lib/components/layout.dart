import 'package:app/components/error_overlay.dart';
import 'package:app/components/invite_dialog.dart';
import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/header.dart';
import '../theme/theme.dart';

void showInviteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const InviteDialog();
    },
  );
}

class Layout extends StatefulWidget {
  final Widget body;
  final String titleText;
  final int currentIndex;
  final bool showHeader;
  final bool showBottomNav;
  final bool isSerif;
  final bool showProfileActions;
  final PreferredSizeWidget? appBarBottom;

  const Layout({
    super.key,
    required this.body,
    this.titleText = 'Dashboard',
    this.currentIndex = 0,
    this.showHeader = true,
    this.showBottomNav = true,
    this.isSerif = false,
    this.showProfileActions = true,
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
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed("/dashboard");
        break;
      case 2:
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
                showProfileActions: widget.showProfileActions,
                isAuthenticated: isAuthenticated,
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
                    height: 32,
                  ),
                ),
              )
            : null,
        body: widget.body,
        floatingActionButton: FutureBuilder<bool>(
          future: Identity.instance.isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: FloatingActionButton(
                    onPressed: () => showInviteDialog(context),
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
                return Text('');
              }
            } else if (snapshot.hasError) {
              print("layout.snapshot.error:${snapshot.error}");
              return onError(snapshot.error!);
            } else {
              return loading ?? const CircularProgressIndicator();
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
    print("onError: ${object}");
    return ErrorOverlay(message: object!.toString(), title: 'Error');
  }
}
