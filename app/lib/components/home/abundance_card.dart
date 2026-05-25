import 'package:app/models/course.dart';
import 'package:app/pages/course.dart';
import 'package:app/pages/user/signin.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../helpers/globals.dart';

class AbundanceCard extends StatelessWidget {
  final CourseData data;
  const AbundanceCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(data.thumbnail ?? ''),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    color: AppColors.primary.withAlpha(80),
                  ),
                ),
              ),
              Positioned(
                bottom: -28,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.accentGold,
                    child: Icon(
                      Icons.diamond_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            data.title ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              data.description ?? '',
              textAlign: TextAlign.left,
              style: TextTheme.of(context).bodySmall,
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<bool>(
            future: Service.course.isEnrolled(data.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              } else if (snapshot.hasData) {
                return ElevatedButton(
                  onPressed: () async {
                    bool flag = await Service.identity.isLoggedIn();
                    if (flag) {
                      navigatorKey.currentState?.push(
                        MaterialPageRoute(
                          builder: (context) =>
                              Course(data: data, enrolled: snapshot.data),
                        ),
                      );
                    } else {
                      navigatorKey.currentState?.push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SignIn(redirect: Course(data: data)),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    snapshot.data == true ? "View Detail" : "Enroll Now",
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
