import 'package:app/services/identity.dart';
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
                       FutureBuilder<bool>(
                         future: Identity.instance
                             .isLoggedIn(), // Your async function
                         builder: (context, snapshot) {
                           if (snapshot.connectionState ==
                               ConnectionState.waiting) {
                             // Show a small loader while waiting
                             return const Padding(
                               padding: EdgeInsets.all(16.0),
                               child: SizedBox(
                                 width: 20,
                                 height: 20,
                                 child: CircularProgressIndicator(
                                   strokeWidth: 2,
                                 ),
                               ),
                             );
                           }

                           if (snapshot.hasData && snapshot.data == true) {
                             // Show Gold Crown for Premium Users
                             return IconButton(
                               icon: const Icon(
                                 Icons.logout,
                                 color: AppColors.primary,
                               ),
                               onPressed: () => Identity.instance.logout(),
                             );
                           }

                           // Default icon for non-premium or error state
                           return Padding(
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
                           );
                         },
                       ),
                     ])
             : null,
       );
}
