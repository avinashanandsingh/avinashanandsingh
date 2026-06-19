import 'package:app/components/course/item.dart';
import 'package:app/models/course.dart';
import 'package:app/models/enroll.dart';
import 'package:app/models/order.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/course.dart';
import 'package:app/pages/order_card.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/alert.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../components/layout.dart';
import 'package:app/helpers/globals.dart';
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
  List<EnrollData> enrollList = List.empty(growable: true);
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
        initialIndex: 0,
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
    return FutureBuilder(
      future: Service.order.list({
        "criteria": [
          {"column": "createdby", "cop": "eq", "value": widget.user.id!},
        ],
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (snapshot.hasData) {
          Result<OrderData> result = snapshot.data!;
          if (result.succeed) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (result.list!.isNotEmpty) ...[
                    Expanded(
                      child: ListView.builder(
                        itemCount: result.list!.length,
                        itemBuilder: (context, index) {
                          return OrderCard(order: result.list![index]);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildCoursesTab() {
    return FutureBuilder(
      future: Service.enrollment.list({
        "criteria": [
          {"column": "userid", "cop": "eq", "value": widget.user.id!},
          {
            "column": "status",
            "cop": "in",
            "lop": "AND",
            "value": ["ENROLLED", "COMPLETED"],
          },
        ],
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (snapshot.hasData) {
          var result = snapshot.data!;
          if (result.succeed) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: result.list!.length,
                      itemBuilder: (context, index) {
                        var item = result.list![index];
                        return GestureDetector(
                          onTap: () async {
                            List<String> statusList = ["ENROLLED", "COMPLETED"];
                            if (statusList.contains(item.status!)) {
                              Result<CourseData>? result = await Service.course
                                  .get({
                                    "criteria": [
                                      {
                                        "column": "id",
                                        "cop": "eq",
                                        "value": item.course?.id,
                                      },
                                    ],
                                  });
                              if (result!.succeed) {
                                navigatorKey.currentState?.push(
                                  MaterialPageRoute(
                                    builder: (context) => Course(
                                      data: result.row,
                                      scheduleId: item.scheduleId,
                                    ),
                                  ),
                                );
                              } else {
                                Alert.show(result.message!, isError: false);
                              }
                            }
                          },
                          child: EnrollItem(data: item),
                        );

                        //_buildCourseCard(result.list![index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildCourseCard(EnrollData item) {
    String dated = "";
    if (item.enrolledat != null) {
      dated = DateFormat.yMMMMEEEEd().format(DateTime.parse(item.enrolledat!));
    }
    return GestureDetector(
      onTap: () async {
        List<String> statusList = ["ENROLLED", "COMPLETED"];
        if (statusList.contains(item.status!)) {
          Result<CourseData>? result = await Service.course.get({
            "criteria": [
              {"column": "id", "cop": "eq", "value": item.course?.id},
            ],
          });
          if (result!.succeed) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) =>
                    Course(data: result.row, scheduleId: item.scheduleId),
              ),
            );
          } else {
            Alert.show(result.message!, isError: false);
          }
        }
      },
      child: Card(
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
                height: 100,
                color: Colors.blue.shade700,
                child: Center(
                  child: Text(
                    item.course!.title ?? '',
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
                          item.status!,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.course!.description ?? '',
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Created On $dated",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
