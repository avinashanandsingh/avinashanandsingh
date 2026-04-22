import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../components/layout.dart';
//import '../page/create_course.dart';
//import '../components/add_enrollment_bottom_sheet.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color primaryPurple = AppColors.primary;
  @override
  initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 2,
    ); // Defaulting to Courses for now
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      titleText: 'YOUR DASHBOARD',
      isSerif: true,
      showProfileActions: false,
      currentIndex: 1,
      appBarBottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primaryPurple,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: "Privacy Policy"),
          Tab(text: "Courses"),
          //Tab(text: "Students"),
          Tab(text: "Marketing"),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(child: Text("Privacy Policy")),
          //_buildCommunityTab(),
          //const Center(child: Text("Notifications")),
          _buildCoursesTab(),
          //_buildStudentsTab(),
          const Center(child: Text("Marketing")),
          //const Center(child: Text("Events")),
        ],
      ),
    );
  }

  Future<bool> isLoggedIn({
    required BuildContext context,
    required bool isAuthenticated,
    required String loginRoute,
  }) async {
    if (!isAuthenticated) {
      // Wait until the current frame is done (microtask queue)
      await Future.microtask(() {});

      // Check if context is still mounted
      if (context.mounted) {
        // Use rootNavigator to bypass nested navigator locks
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushReplacementNamed(loginRoute);
        });
      }
      return false;
    }
    return true;
  }

  Widget _buildCoursesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) {
                return _buildCourseCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.withAlpha(50)),
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 160,
              color: Colors.blue.shade700,
              child: const Center(
                child: Text(
                  "LEARN SOFTWARE\nDEVELOPMENT\nWITH US!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "APPROVED",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "BEGINNER'S GUIDE TO BECOMING A PROFESSIONAL FRONTEND DEVELOPER",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Serif',
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Created On 2nd Feb, 2026",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.signal_cellular_alt,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Beginner",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "60,000 Students Enrolled",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "₹2,400",
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
