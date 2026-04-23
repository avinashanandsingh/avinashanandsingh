import 'package:app/pages/signin.dart';
import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class ActionIconData {
  ActionIconData();
  Future<List<Widget>> list() async {
    List<Widget> lst = [];
    dynamic user = await Identity.instance.me();
    if (user != null) {
      lst.add(
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black87),
          onPressed: () {},
        ),
      );
      // Profile
      lst.add(
        Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushReplacementNamed("/profile");
            },
            child: Container(
              padding: EdgeInsets.all(0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(user['avatar']),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      );
      lst.add(
        Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.logout, color: AppColors.primary),
              onPressed: () {
                Identity.instance.logout();
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushReplacementNamed("/home");
              },
            );
          },
        ),
      );
    } else {
      lst.add(
        Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignIn()),
                  );
                },
                icon: Icon(Icons.login, color: AppColors.primary, size: 20),
              ),
            );
          },
        ),
      );
    }
    return lst;
  }
}
