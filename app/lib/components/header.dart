import 'package:flutter/material.dart';
import '../components/action_icon_data.dart';
import '../components/title_widget.dart';
import '../models/user.dart';
import '../services/identity.dart';
import '../theme/theme.dart';

class Header extends AppBar {
  Header({
    super.key,
    required String titleText,
    bool isSerif = false,
    bool showActions = true,
    bool isAuthenticated = true,
    super.bottom,
    super.leading,
    Color primaryColor = AppColors.primary,
  }) : super(
         backgroundColor: Colors.white,
         elevation: 0,
         centerTitle: false,
         leadingWidth: 48,
         title: Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             if (isSerif) ...[
               FutureBuilder<UserData?>(
                 future: Identity.instance.me(),
                 builder: (context, snapshot) {
                   if (snapshot.hasData) {
                     if (snapshot.data != null) {
                       return TitleWidget(
                         title: 'Hi, ${snapshot.data!.firstName}',
                       );
                     } else {
                       return TitleWidget(title: titleText);
                     }
                   } else {
                     return TitleWidget(title: titleText);
                   }
                 },
               ),
             ] else ...[
               TitleWidget(title: titleText),
             ],
           ],
         ),
         actions: showActions
             ? [
                 FutureBuilder<List<Widget>>(
                   future: ActionIconData().list(),
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
                       // Return dynamic actions once data is ready
                       return Row(
                         children: snapshot.data!.map((icon) => icon).toList(),
                       );
                     }
                     return Container(); // Handle error or empty state
                   },
                 ),
               ]
             : [],
       );
}
