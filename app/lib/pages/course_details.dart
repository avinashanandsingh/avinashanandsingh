import 'package:app/models/course.dart';
import 'package:app/pages/course/private.dart';
import 'package:app/pages/course/public.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class CourseDetails extends StatefulWidget {
  final CourseData? data;
  const CourseDetails({super.key, this.data});

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  //final int _bottomNavIndex = 1;
  static const Color primaryPurple = AppColors.primary;

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    int tabs = 2;
    if (widget.data!.certified!) {
      tabs = 3;
    }
    _tabController = TabController(length: tabs, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Service.identity.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data!) {
            return PrivateCourse(data: widget.data);
          } else {
            return PublicCourse(data: widget.data);
          }
        } else {
          return PublicCourse(data: widget.data);
        }
      },
    );
  }
}
