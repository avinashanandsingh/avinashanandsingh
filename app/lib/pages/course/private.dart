import 'package:app/components/custom_tab_view.dart';
import 'package:app/components/price_tag.dart';
import 'package:app/components/review_dialog.dart' as review_dialog;
import 'package:app/components/review_widget.dart';
import 'package:app/components/video_card.dart';
import 'package:app/models/course.dart';
import 'package:app/models/order.dart';
import 'package:app/models/qna.dart';
import 'package:app/pages/course_details.dart';
import 'package:app/pages/enroll.dart';
import 'package:app/pages/signin.dart';
import 'package:app/services/identity.dart';
import 'package:app/services/service.dart';
import 'package:app/theme/theme.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/helpers/globals.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PrivateCourse extends StatefulWidget {
  final CourseData? data;
  const PrivateCourse({super.key, this.data});

  @override
  State<PrivateCourse> createState() => PrivateCourseState();
}

class PrivateCourseState extends State<PrivateCourse>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late AppTheme theme = AppTheme();
  int tabs = 2;
  late Future<List<QnaData>> qna = Service.qna.list(widget.data?.id ?? '');
  @override
  void initState() {
    super.initState();
    qna = Service.qna.list(widget.data?.id ?? '');
    if (widget.data!.modules != null) {
      tabs += 1;
    }
    if (widget.data!.certified!) {
      tabs += 1;
    }
    tabController = TabController(length: tabs, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.data!.title!),
          titleTextStyle: TextTheme.of(context).headlineSmall,
          centerTitle: false,
        ),
        body: Container(
          padding: EdgeInsets.all(0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Tells column to be only as big as needed
              children: [
                headerInfo(),
                metadataGrid(),

                Divider(),
                Container(
                  padding: EdgeInsets.all(15),
                  child: FutureBuilder(
                    future: Service.schedule.get({
                      "criteria": [
                        {
                          "column": "courseid",
                          "cop": "eq",
                          "value": widget.data?.id,
                        },
                        {
                          "column": "status",
                          "cop": "eq",
                          "lop": "AND",
                          "value": "ACTIVE",
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
                        if (snapshot.data != null) {
                          String formattedStartDate = DateFormat.yMMMMEEEEd()
                              .format(
                                DateTime.parse(snapshot.data!.startDate!),
                              );
                          String formattedEndDate = DateFormat.yMMMMEEEEd()
                              .format(DateTime.parse(snapshot.data!.endDate!));

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data!.title!,
                                style: TextTheme.of(context).headlineSmall,
                              ),

                              Row(
                                children: [
                                  Text(
                                    "Start Date: ",
                                    style: TextTheme.of(context).labelSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    formattedStartDate,
                                    style: TextTheme.of(context).labelSmall,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "End Date: ",
                                    style: TextTheme.of(context).labelSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    formattedEndDate,
                                    style: TextTheme.of(context).labelSmall,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Time: ",
                                    style: TextTheme.of(context).labelSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${snapshot.data!.formattedStartTime!} to ${snapshot.data!.formattedEndTime!}",
                                    style: TextTheme.of(context).labelSmall,
                                  ),
                                ],
                              ),
                              /* Row(
                                children: [
                                  Text(
                                    "End Time: ",
                                    style: TextTheme.of(context).labelSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(snapshot.data!.formattedEndTime!),
                                ],
                              ), */
                            ],
                          );
                        } else {
                          return Container();
                        }
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                  child: FutureBuilder<bool>(
                    future: Service.course.isEnrolled(widget.data!.id!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        if (!snapshot.data!) {
                          if (widget.data!.free!) {
                            return TextButton(
                              onPressed: () async {
                                print('clicked free');
                                bool flag = await Identity.instance
                                    .isLoggedIn();
                                print(flag);
                                if (flag) {
                                  /* navigatorKey.currentState?.push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Enroll(course: widget.data!),
                                    ),
                                  ); */
                                } else {
                                  navigatorKey.currentState?.push(
                                    MaterialPageRoute(
                                      builder: (context) => SignIn(
                                        redirect: CourseDetails(
                                          data: widget.data,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Enroll Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            return Row(
                              children: [
                                PriceTag(
                                  offer: widget.data!.offer ?? 0.00,
                                  price: widget.data!.price ?? 0.00,
                                ),
                                Spacer(),
                                TextButton(
                                  onPressed: () async {
                                    print('clicked');
                                    bool flag = await Identity.instance
                                        .isLoggedIn();
                                    print(flag);
                                    if (flag) {
                                      if (widget.data!.short!) {
                                        print('is a short course');
                                      } else {
                                        navigatorKey.currentState?.push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Enroll(course: widget.data!),
                                          ),
                                        );
                                      }
                                    } else {
                                      navigatorKey.currentState?.push(
                                        MaterialPageRoute(
                                          builder: (context) => SignIn(
                                            redirect: CourseDetails(
                                              data: widget.data,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Enroll Now',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        } else {
                          return Container();
                        }
                      }
                      return Container();
                    },
                  ),
                ),

                Divider(),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                  child: VideoCard(url: widget.data!.url!),
                ),
                tabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    String? orderId = await Service.store.get("latest_order_id");
    OrderData orderData = OrderData(
      orderStatus: "CONFIRMED",
      orderStatusReason: 'Your payment was successful and order is confirmed',
      paymentStatus: "PAID",
      paymentStatusReason: 'Your payment was successful',
      paymentid: response.paymentId,
      signature: response.signature,
      updatedat: DateTime.now(),
    );
    OrderData? order = await Service.order.update(orderId!, orderData);
    if (order?.id == null) {
      Alert.show(
        "Payment was successful but failed to update order. Please contact support.",
        isError: true,
      );
    } else {
      Alert.show(
        "Payment Successful! Your order is confirmed.",
        isError: false,
      );
    }
  }

  void handlePaymentError(PaymentFailureResponse response) async {
    if (response.code == 0) {
      String? orderId = await Service.store.get("latest_order_id");
      OrderData orderData = OrderData(
        paymentStatus: "CANCELLED",
        paymentStatusReason: response.message,
        updatedat: DateTime.now(),
      );
      OrderData? order = await Service.order.update(orderId!, orderData);
      if (order != null) {
        Alert.show("Payment cancelled.", isError: false);
      }
    }
    Alert.show("Payment Failed: ${response.message}", isError: true);
  }

  Widget headerInfo() {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Text(widget.data!.title!, style: TextTheme.of(context).headlineSmall),
          //const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dotenv.env['AUTHOR'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    dotenv.env['AUTHOR_EMAIL'] ?? '',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget metadataGrid() {
    int modules = widget.data?.modules?.length ?? 0;
    final metadata = [
      {
        'icon': Icons.star,
        'iconColor': Colors.orange,
        'text':
            '${widget.data!.rating ?? 0} (${widget.data!.reviews ?? 0} Reviews)',
      },
      {'icon': Icons.language, 'iconColor': Colors.grey, 'text': 'English'},
      {
        'icon': Icons.insert_drive_file_outlined,
        'iconColor': Colors.grey,
        'text': widget.data!.certified! ? 'Certified' : 'Non-Certified',
      },
      {
        'icon': Icons.grid_view,
        'iconColor': Colors.grey,
        'text': '$modules Modules',
      },
      {
        'icon': Icons.person_outline,
        'iconColor': Colors.grey,
        'text': '500 Enrolled Student',
      },
      {
        'icon': Icons.access_time,
        'iconColor': Colors.grey,
        'text': widget.data!.duration!,
      },
      {
        'icon': Icons.calendar_today,
        'iconColor': Colors.grey,
        'text': 'Validity: ${widget.data!.validity} days',
      },
      {
        'icon': Icons.signal_cellular_alt,
        'iconColor': Colors.grey,
        'text': widget.data!.level ?? 'N/A',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: metadata.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 8,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (context, index) {
          final item = metadata[index];
          return Row(
            children: [
              Icon(
                item['icon'] as IconData,
                color: item['iconColor'] as Color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['text'] as String,
                  style: TextTheme.of(context).labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget tabBar() {
    return TabBar(
      controller: tabController,
      isScrollable: true,
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: Colors.grey,
      indicatorColor: AppColors.primary,
      tabAlignment: TabAlignment.start,
      indicatorWeight: 3,
      labelStyle: TextTheme.of(context).labelSmall,
      tabs: [
        const Tab(text: "Overview"),
        if (widget.data?.modules != null) const Tab(text: "Curriculum"),
        if (widget.data!.certified!) const Tab(text: "Certificates"),
      ],
    );
  }

  Widget tabContent() {
    return CustomTabView(
      controller: tabController,
      tabs: [
        Tab(text: "Overview"),
        if (widget.data?.modules != null) Tab(text: "Curriculum"),
        if (widget.data!.certified!) Tab(text: "Certificates"),
        Tab(text: 'Review'),
      ],
      children: [
        overview(),
        if (widget.data?.modules != null) curriculum(),
        //_buildForumTab(),
        if (widget.data!.certified!) certificate(),
        Container(padding: EdgeInsets.all(15), child: ReviewWidget()),
      ],
    );

    /* return TabBarView(
      controller: tabController,
      children: [
        overview(),
        if (widget.data?.modules != null) curriculum(),
        //_buildForumTab(),
        if (widget.data!.certified!) certificate(),
      ],
    ); */
  }

  Widget overview() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "ABOUT COURSE",
              style: GoogleFonts.montserrat(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton.icon(
              onPressed: () => review_dialog.show(context, widget.data),
              icon: const Icon(
                Icons.rate_review_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(
                "Write Review",
                style: GoogleFonts.montserrat(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Text(widget.data!.description!.trim()),
        if (widget.data!.about != null) ...[
          Text(
            widget.data!.about!.trim(),
            style: TextTheme.of(context).bodyMedium,
          ),
        ],
      ],
    );
  }

  Widget curriculum() {
    final ml = widget.data?.modules;
    //print(widget.data?.toJson());
    final List<Map<String, dynamic>> list = List.empty(growable: true);
    int i = 1;
    for (var item in ml) {
      //print(item);
      list.add({
        "num": i,
        "id": item['id'],
        "title": item['title'],
        "time": item['duration'],
        "completed": item['completed'],
      });
    }
    final modules = [
      {'num': '1', 'title': 'Introduction', 'time': '10:00', 'status': 'done'},
      {
        'num': '2',
        'title': 'What is UX Design',
        'time': '2:30 / 10:00',
        'status': 'active',
      },
      {
        'num': '3',
        'title': 'Usability Testing',
        'time': '10:00',
        'status': 'pending',
      },
      {
        'num': '4',
        'title': 'Create Usability Test',
        'time': '30:00',
        'status': 'pending',
      },
      {
        'num': '5',
        'title': 'How to Implement',
        'time': '30:00',
        'status': 'pending',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const Text(
          "5 MODULES",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontFamily: 'Serif',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(flex: 1, child: Container(height: 4, color: Colors.amber)),
            Expanded(
              flex: 4,
              child: Container(height: 4, color: Colors.grey.shade200),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "1/5 Done",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "20%",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...modules.map((m) {
          bool isDone = m['status'] == 'done';
          bool isActive = m['status'] == 'active';
          /* return FutureBuilder<bool>(
            future: widget.data.modules,
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
                if (snapshot.data!) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: FloatingActionButton(
                      onPressed: () => InviteDialog.show(context),
                      elevation: 8,
                      shape: const CircleBorder(),
                      backgroundColor: AppColors.accentGold,
                      child: const Icon(
                        Icons.share,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              } else {
                return Container();
              }
            },
          ); */
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: [
                if (isDone)
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  )
                else if (isActive)
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      m['num']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey.shade100,
                    child: Text(
                      m['num']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    m['title']!,
                    style: TextStyle(
                      color: isDone ? Colors.grey : Colors.black87,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Text(
                  m['time']!,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget certificate() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.insert_drive_file,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AIML Certificate",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "PDF • 2.4 MB • 42 pages",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.download,
                  color: AppColors.primary,
                  size: 18,
                ),
                label: const Text(
                  "Download",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
