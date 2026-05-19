import 'package:app/components/loader.dart';
import 'package:app/models/order.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/order_card.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/alert.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../components/layout.dart';
//import '../page/create_course.dart';
//import '../components/add_enrollment_bottom_sheet.dart';

class Dashboard extends StatefulWidget {
  final UserData user;
  const Dashboard({super.key, required this.user});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  static const Color primaryPurple = AppColors.primary;
  List<OrderData> orderList = List.empty(growable: true);
  @override
  initState() {
    super.initState();
    orderList = [];
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      titleText: 'Dashboard',
      showHeader: true,
      isSerif: false,
      showBottomNav: true,
      showActions: true,
      showBack: true,
      currentIndex: 2,
      body: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Tells column to be only as big as needed

          children: [
            TabBar(
              tabs: const [
                Tab(text: "My Courses"),
                Tab(text: "Order History"),
              ],
              labelColor: Colors.black,
              onTap: (idx) async {
                switch (idx) {
                  case 0:
                    break;
                  case 1:
                    Loader.show();
                    Result<OrderData> result = await Service.order.list({
                      "criteria": [
                        {
                          "column": "createdby",
                          "cop": "eq",
                          "value": widget.user.id!,
                        },
                      ],
                    });
                    Loader.hide();
                    if (result.succeed) {
                      setState(() {
                        orderList = result.data!;
                      });
                    } else {
                      Alert.show(result.message!, isError: true);
                    }
                    break;
                }
              },
            ),
            // Wrapping in a Flexible or Expanded only works if
            // the parent of this Column has a constrained height!
            Expanded(
              child: TabBarView(children: [_buildCoursesTab(), orderListTab()]),
            ),
          ],
        ),
      ),
    );
  }

  Widget orderListTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (orderList.isNotEmpty) ...[
            Expanded(
              child: ListView.builder(
                itemCount: orderList.length,
                itemBuilder: (context, index) {
                  return OrderCard(order: orderList[index]);
                },
              ),
            ),
          ],
        ],
      ),
    );
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
