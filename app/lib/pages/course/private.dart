import 'package:app/components/layout.dart';
import 'package:app/components/price_tag.dart';
import 'package:app/components/review_dialog.dart' as review_dialog;
import 'package:app/models/course.dart';
import 'package:app/services/identity.dart';
import 'package:app/services/service.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  @override
  void initState() {
    super.initState();
    if (widget.data!.certified!) {
      tabs = 3;
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
      titleText: widget.data!.title!,
      isSerif: false,
      showHeader: true,
      showBack: true,
      showBottomNav: true,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              headerInfo(),
              metadataGrid(),
              SizedBox(height: 5),
              tabBar(),
              //SizedBox(height: 3),
              tabContent(),
              SizedBox(height: 5),

              FutureBuilder<bool>(
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
                            bool flag = await Identity.instance.isLoggedIn();
                            if (flag) {
                              print('clicked');
                            } else {
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pushReplacementNamed("/signin");
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
                                bool flag = await Identity.instance
                                    .isLoggedIn();
                                if (flag) {
                                } else {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushReplacementNamed("/signin");
                                }
                                print('clicked');
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
            ],
          ),
        ),
      ),
    );
  }

  Widget headerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.data!.title!, style: TextTheme.of(context).headlineSmall),
        const SizedBox(height: 16),
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
                const Text(
                  "Avinash Anand Singh",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  "avinashanandsingh@gmail.com",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget metadataGrid() {
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
      {'icon': Icons.grid_view, 'iconColor': Colors.grey, 'text': '5 Modules'},
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: metadata.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
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
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
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
        const Tab(text: "Curriculum"),
        if (widget.data!.certified!) const Tab(text: "Certificates"),
      ],
    );
  }

  Widget tabContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 1.2,
      child: TabBarView(
        controller: tabController,
        children: [
          overview(),
          curriculum(),
          //_buildForumTab(),
          if (widget.data!.certified!) certificate(),
        ],
      ),
    );
  }

  Widget overview() {
    return ListView(
      padding: const EdgeInsets.all(10.0),
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
              onPressed: () => review_dialog.show(context),
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
        Text(widget.data!.description!),
        if (widget.data!.about != null) ...[
          Text(widget.data!.about!, style: TextTheme.of(context).bodyMedium),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget curriculum() {
    final ml = widget.data!.modules!;
    final List<Map<String, dynamic>> list = List.empty(growable: true);
    int i = 1;
    for (var item in ml) {
      print(item);
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
