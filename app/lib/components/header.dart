import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../pages/signin.dart';

class Header extends AppBar {
  Header({
    super.key,
    required String titleText,
    bool isSerif = false,
    bool showProfileActions = true,
    bool isAuthenticated = true,
    super.bottom,
    super.leading,
    Color primaryColor = AppColors.primary,
  }) : super(
         backgroundColor: Colors.white,
         elevation: 0,
         centerTitle: false,
         title: Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             Text(
               isAuthenticated ? titleText : "Welcome Back!",
               style: TextStyle(
                 color: isSerif ? primaryColor : Colors.black87,
                 fontSize: isSerif ? 20 : 18,
                 fontWeight: isSerif ? FontWeight.normal : FontWeight.w500,
                 fontFamily: isSerif ? 'Serif' : null,
                 letterSpacing: isSerif ? 1.2 : 0,
               ),
             ),
           ],
         ),
         actions: showProfileActions
             ? (isAuthenticated
                   ? [
                       Builder(
                         builder: (context) => IconButton(
                           icon: const Icon(
                             Icons.notifications_none,
                             color: Colors.black87,
                           ),
                           onPressed: () {},
                         ),
                       ),
                       Builder(
                         builder: (context) => GestureDetector(
                           onTap: () {
                             /* Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => const Profile(),
                               ),
                             ); */
                             Navigator.of(
                               context,
                               rootNavigator: true,
                             ).pushReplacementNamed("/profile");
                           },
                           child: Container(
                             margin: const EdgeInsets.only(right: 16, left: 8),
                             child: CircleAvatar(
                               backgroundColor: Colors.pink.shade100,
                               radius: 16,
                               child: const Text(
                                 'A',
                                 style: TextStyle(
                                   color: Colors.pink,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                             ),
                           ),
                         ),
                       ),
                     ]
                   : [
                       Builder(
                         builder: (context) => Padding(
                           padding: const EdgeInsets.only(right: 12.0),
                           child: IconButton(
                             onPressed: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => const SignIn(),
                                 ),
                               );
                             },
                             icon: Icon(
                               Icons.login,
                               color: primaryColor,
                               size: 20,
                             ),
                           ),
                         ),
                       ),
                     ])
             : null,
       );
}
