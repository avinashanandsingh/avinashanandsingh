import 'package:app/components/layout.dart';
import 'package:app/components/price_tag.dart';
import 'package:app/models/course.dart';
import 'package:app/pages/course_details.dart';
import 'package:app/pages/signin.dart';
import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';
import 'package:app/helpers/globals.dart';

class PublicCourse extends StatefulWidget {
  final CourseData? data;
  const PublicCourse({super.key, this.data});

  @override
  State<PublicCourse> createState() => PublicCourseState();
}

class PublicCourseState extends State<PublicCourse>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int tabs = 1;
  @override
  void initState() {
    super.initState();
    if (widget.data!.certified!) {
      tabs = 2;
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
              Text('Overview', style: TextTheme.of(context).headlineSmall),
              Text(widget.data!.description!),
              SizedBox(height: 5),
              if (widget.data!.about != null) ...[
                Text(
                  widget.data!.about!,
                  style: TextTheme.of(context).bodyMedium,
                ),
                SizedBox(height: 16),
              ],
              if (!widget.data!.free!) ...[
                Row(
                  children: [
                    PriceTag(
                      offer: widget.data!.offer ?? 0.00,
                      price: widget.data!.price ?? 0.00,
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        bool flag = await Identity.instance.isLoggedIn();
                        if (!flag) {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) => SignIn(
                                redirect: CourseDetails(data: widget.data),
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
                ),
              ],
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
      {
        'icon': Icons.grid_view,
        'iconColor': Colors.grey,
        'text':
            '${widget.data!.modules == null ? 0 : widget.data!.modules.length} Modules',
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
}
