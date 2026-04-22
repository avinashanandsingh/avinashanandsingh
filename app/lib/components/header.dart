import 'package:app/components/error_overlay.dart';
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
           mainAxisSize: MainAxisSize.max,
           children: [
             FutureBuilder<bool>(
               future: Identity.instance.isLoggedIn(),
               builder: (context, snapshot) {
                 if (snapshot.hasData) {
                   if (snapshot.data!) {
                     return Flexible(
                       child: Text(
                         titleText,
                         overflow: TextOverflow.ellipsis,
                         style: TextStyle(
                           color: isSerif ? primaryColor : Colors.black87,
                           fontSize: isSerif ? 20 : 18,
                           fontWeight: isSerif
                               ? FontWeight.normal
                               : FontWeight.w500,
                           fontFamily: isSerif ? 'Serif' : null,
                           letterSpacing: isSerif ? 1.2 : 0,
                         ),
                       ),
                     );
                   } else {
                     return Flexible(
                       child: Text(
                         "Welcome back!",
                         overflow: TextOverflow.ellipsis,
                         style: TextStyle(
                           color: isSerif ? primaryColor : Colors.black87,
                           fontSize: isSerif ? 20 : 18,
                           fontWeight: isSerif
                               ? FontWeight.normal
                               : FontWeight.w500,
                           fontFamily: isSerif ? 'Serif' : null,
                           letterSpacing: isSerif ? 1.2 : 0,
                         ),
                       ),
                     );
                   }
                 } else if (snapshot.hasError) {
                   return ErrorOverlay(
                     message: snapshot.error!.toString(),
                     title: 'Error',
                   );
                 } else {
                   return leading ?? const CircularProgressIndicator();
                 }
               },
             ),
           ],
         ),
         actions: showProfileActions
             ? [
                 FutureBuilder<bool>(
                   future: Identity.instance.isLoggedIn(),
                   builder: (context, snapshot) {
                     if (snapshot.hasData) {
                       if (snapshot.data!) {
                         return Builder(
                           builder: (context) => IconButton(
                             icon: const Icon(
                               Icons.notifications_none,
                               color: Colors.black87,
                             ),
                             onPressed: () {},
                           ),
                         );
                       } else {
                         return Text('');
                       }
                     } else if (snapshot.hasError) {
                       return ErrorOverlay(
                         message: snapshot.error!.toString(),
                         title: 'Error',
                       );
                     } else {
                       return leading ?? const CircularProgressIndicator();
                     }
                   },
                 ),
                 FutureBuilder<bool>(
                   future: Identity.instance.isLoggedIn(),
                   builder: (context, snapshot) {
                     if (snapshot.hasData) {
                       if (snapshot.data!) {
                         return Builder(
                           builder: (context) => GestureDetector(
                             onTap: () {
                               Navigator.of(
                                 context,
                                 rootNavigator: true,
                               ).pushReplacementNamed("/profile");
                             },
                             child: Container(
                               margin: const EdgeInsets.only(
                                 right: 16,
                                 left: 8,
                               ),
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
                         );
                       } else {
                         return Text('');
                       }
                     } else if (snapshot.hasError) {
                       return ErrorOverlay(
                         message: snapshot.error!.toString(),
                         title: 'Error',
                       );
                     } else {
                       return leading ?? const CircularProgressIndicator();
                     }
                   },
                 ),
                 FutureBuilder<bool>(
                   future: Identity.instance
                       .isLoggedIn(), // Your async function
                   builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting) {
                       // Show a small loader while waiting
                       return const Padding(
                         padding: EdgeInsets.all(16.0),
                         child: SizedBox(
                           width: 20,
                           height: 20,
                           child: CircularProgressIndicator(strokeWidth: 2),
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
                         onPressed: () {
                           Identity.instance.logout();
                           Navigator.of(
                             context,
                             rootNavigator: true,
                           ).pushReplacementNamed("/home");
                         },
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
                         icon: Icon(Icons.login, color: primaryColor, size: 20),
                       ),
                     );
                   },
                 ),

                 /*  Builder(
                   builder: (context) => GestureDetector(
                     onTap: () {
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
                 ), */
               ]
             : [],
       );
}
