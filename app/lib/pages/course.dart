import 'package:app/components/custom_tab_view.dart';
import 'package:app/components/layout.dart';
import 'package:app/components/loader.dart';
import 'package:app/components/price_tag.dart';
import 'package:app/components/review_dialog.dart' as review_dialog;
import 'package:app/components/review_widget.dart';
import 'package:app/components/schedule_card.dart';
import 'package:app/components/video_card.dart';
import 'package:app/helpers/enroll.dart';
import 'package:app/models/course.dart';
import 'package:app/models/module.dart';
import 'package:app/models/order.dart';
import 'package:app/models/qna.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/enroll.dart';
import 'package:app/pages/home.dart';
import 'package:app/services/razorpay.dart';
import 'package:app/services/service.dart';
import 'package:app/theme/theme.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/helpers/globals.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../components/video_player_dialog.dart' as video_dialog;

class Course extends StatefulWidget {
  final CourseData? data;
  final bool? enrolled;
  final String? scheduleId;
  const Course({super.key, this.data, this.scheduleId, this.enrolled});

  @override
  State<Course> createState() => CourseState();
}

class CourseState extends State<Course> with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool paid = false;
  late AppTheme theme = AppTheme();
  int tabs = 2;
  late Future<List<QnaData>> qna = Service.qna.list(widget.data?.id ?? '');
  @override
  void initState() {
    super.initState();
    paid = false;
    qna = Service.qna.list(widget.data?.id ?? '');
    if (widget.data!.modules!.isNotEmpty) {
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
    return Layout(
      titleText: 'Course Details',
      showHeader: true,
      isSerif: false,
      showBottomNav: true,
      showActions: true,
      showBack: true,
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
              schedule(),
              if (widget.enrolled == false) ...[
                if (widget.data!.free!) ...[
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                    child: freeWidget(),
                  ),
                ] else ...[
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                    child: paidWidget(),
                  ),
                ],
              ],
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
    );
  }

  void checkout() async {
    bool bought = await Service.order.bought(widget.data!.id!, "SHORT_COURSE");
    if (bought) {
      Alert.show(
        "You're enrolled! Jump back into your learning.",
        isError: false,
      );
    } else {
      var payment = await Service.setting.get('PAYMENT');
      dynamic user = await Service.identity.me();

      var orderData = OrderData(
        context: "SHORT_COURSE",
        contextid: widget.data!.id!,
        price: widget.data!.sale,
        orderStatus: "INITIATED",
        orderStatusReason: 'Your order has been initiated and awaiting payment',
        paymentStatus: "PENDING",
        createdat: DateTime.now(),
      );
      var order = await Service.order.add(orderData);

      if (order?.id == null) {
        Alert.show("Failed to create order. Please try again.", isError: true);
      } else {
        if (payment == 'ON') {
          await Service.store.set("latest_order_id", order!.id!);
          var userData = UserData.fromJson(user);
          RazorpayService.instance.startPayment(
            onSuccess: handlePaymentSuccess,
            onFailure: handlePaymentError,
            options: {
              'key': dotenv.env['RAZORPAY_KEY'] ?? '', // Replace with your key
              'currency': 'INR',
              'amount':
                  1 * 100, // amount in the smallest currency unit amount * 100
              'name': dotenv.env['COMPANY'] ?? '',
              'description': "Short Course - ${widget.data!.title}",
              'timeout': 300, // in seconds
              'prefill': {
                "name":
                    "${userData.firstName ?? ''} ${userData.lastName ?? ''}",
                "contact": userData.phone,
                "email": userData.email,
              },
              'theme': {'color': '#5A2A82'},
              'modal': {'confirm_close': true, 'handle_back': true},
            },
          );
        }
      }
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      paid = true;
    });
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
    setState(() {
      paid = false;
    });
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

  Widget tabContent() {
    return CustomTabView(
      controller: tabController,
      tabs: [
        Tab(text: "Overview"),
        if (widget.data!.modules!.isNotEmpty) Tab(text: "Curriculum"),
        if (widget.data!.certified!) Tab(text: "Certificates"),
        Tab(text: 'Review'),
      ],
      children: [
        overview(),
        if (widget.data!.modules!.isNotEmpty) curriculum(),
        //_buildForumTab(),
        if (widget.data!.certified!) certificate(),
        Container(
          padding: EdgeInsets.all(15),
          child: ReviewWidget(type: "COURSE", id: widget.data!.id!),
        ),
      ],
    );
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
    List<ModuleData> list = widget.data!.modules ?? [];
    int total = list.length;
    int done = 0;
    if (list.isNotEmpty) {
      done = 0; // list.where((x) => x.completed == true).toList().length;
    }
    return ListView(
      padding: const EdgeInsets.all(16.0),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text(
          "${list.length} MODULES",
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
          children: [
            Text(
              "$done/$total Done",
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "0%",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (list.isNotEmpty) ...[
          ...list.map((m) {
            bool isDone = false;
            bool isActive = !(false);
            return GestureDetector(
              onTap: () async {
                var enrolled = await Service.course.isEnrolled(m.courseId!);
                if (enrolled) {
                  video_dialog.show(
                    context,
                    url: m.url!,
                    trackingEnable: true,
                    moduleId: m.id,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  children: [
                    if (widget.enrolled == true)
                      // ignore: dead_code
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.purple,
                        child: Icon(
                          Icons.lock_open_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.purple,
                        child: Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),

                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        m.title!,
                        style: TextTheme.of(context).labelSmall!.copyWith(
                          color: isDone ? Colors.grey : Colors.black87,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Text(
                      m.duration!,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
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

  Widget freeWidget() {
    return TextButton(
      onPressed: () async {
        print('clicked free');
        Loader.show();
        var result = await EnrollHelper.initiate(widget.data!.id!);
        Loader.hide();
        if (result.succeed) {
          EnrollHelper.enrolled(result.id!);
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else {
          Alert.show(result.message!, isError: true);
        }
      },
      child: Text(
        'Enroll Now',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget paidWidget() {
    return Row(
      children: [
        PriceTag(
          offer: widget.data!.offer ?? 0.00,
          price: widget.data!.price ?? 0.00,
        ),
        Spacer(),
        TextButton(
          onPressed: () async {
            if (widget.data!.short!) {
              Loader.show();
              var result = await EnrollHelper.initiate(widget.data!.id!);
              Loader.hide();

              if (result.succeed) {
                checkout();
                if (paid) {
                  result = await EnrollHelper.enrolled(result.id!);
                  if (result.succeed) {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  } else {
                    Alert.show(result.message!, isError: true);
                  }
                }
              } else {
                setState(() {
                  paid = false;
                });
                Alert.show(result.message!, isError: true);
              }
            } else {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => Enroll(course: widget.data!),
                ),
              );
            }
          },
          child: Text(
            'Enroll Now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget schedule() {
    if (widget.scheduleId != null) {
      String courseId = widget.data!.id!;
      return FutureBuilder(
        future: Service.schedule.get({
          if (widget.scheduleId == null)
            "criteria": [
              {"column": "courseid", "cop": "eq", "value": courseId},
              {
                "column": "status",
                "cop": "eq",
                "lop": "AND",
                "value": "ACTIVE",
              },
              {"column": "id", "cop": "eq", "value": widget.scheduleId},
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
              return ScheduleCard(data: snapshot.data!);
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        },
      );
    } else {
      if (widget.data!.schedule != null) {
        return ScheduleCard(data: widget.data!.schedule!);
      } else {
        return Container();
      }
    }
  }
}
