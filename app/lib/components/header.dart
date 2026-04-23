import 'package:app/components/action_icon_data.dart';
import 'package:app/components/error_overlay.dart';
import 'package:app/components/title_widget.dart';
import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';
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
         leadingWidth: 64,
         title: Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             if (isSerif) ...[
               FutureBuilder<dynamic>(
                 future: Identity.instance.me(),
                 builder: (context, snapshot) {
                   if (snapshot.hasData) {
                     if (snapshot.data != null) {
                       return TitleWidget(
                         title: 'Hi, ${snapshot.data['first_name']}',
                       );
                     } else {
                       return TitleWidget(title: titleText);
                     }
                   } else if (snapshot.hasError) {
                     return ErrorOverlay(
                       message: snapshot.error!.toString(),
                       title: 'Error',
                     );
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
