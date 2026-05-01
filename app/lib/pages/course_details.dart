import 'package:app/components/image_card.dart';
import 'package:app/components/video_card.dart';
import 'package:app/models/course.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../components/header.dart';
import '../components/bottom_nav.dart';
import 'home.dart';

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
    print('tabs ${tabs}');
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Header(titleText: 'Hi, Raj!'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(widget.data!),
            _buildMetadataGrid(widget.data!),
            //_buildVideoPlayer(),
            ImageCard(
              url: widget.data!.thumbnail!,
              height: 500,
              borderRadius: 8,
            ),
            _buildTabBar(widget.data!),
            _buildTabContent(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex:
            1, // Assume "My Courses" is selected since this is a course
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
              (route) => false,
            );
          } else if (index == 2) {
            /* showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const CreateCommunityBottomSheet(),
            ); */
          }
        },
      ),
    );
  }

  Widget _buildHeaderInfo(CourseData d) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            d.title!,
            style: TextStyle(
              color: primaryPurple,
              fontSize: 20,
              fontFamily: 'Serif',
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
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
      ),
    );
  }

  Widget _buildMetadataGrid(CourseData d) {
    final metadata = [
      {
        'icon': Icons.star,
        'iconColor': Colors.orange,
        'text': '${d.rating ?? 0} (${d.reviews ?? 0} Reviews)',
      },
      {'icon': Icons.language, 'iconColor': Colors.grey, 'text': 'English'},
      {
        'icon': Icons.insert_drive_file_outlined,
        'iconColor': Colors.grey,
        'text': d.certified! ? 'Certified' : 'Non-Certified',
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
        'text': d.duration!,
      },
      {
        'icon': Icons.calendar_today,
        'iconColor': Colors.grey,
        'text': 'Validity: ${d.validity} days',
      },
      {
        'icon': Icons.signal_cellular_alt,
        'iconColor': Colors.grey,
        'text': d.level ?? 'N/A',
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

  Widget _buildVideoPlayer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Placeholder for video
              Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white.withAlpha(200),
                  size: 64,
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(100),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.pause, color: Colors.white, size: 16),
                            SizedBox(width: 12),
                            Icon(
                              Icons.fast_rewind,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 12),
                            Icon(
                              Icons.fast_forward,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            Text(
                              "47:38 / 1:52:32",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(
                              Icons.volume_up,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 12),
                            Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(CourseData? d) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      indicatorColor: primaryPurple,
      tabAlignment: TabAlignment.start,
      indicatorWeight: 3,
      tabs: [
        const Tab(text: "Overview"),
        const Tab(text: "Curriculum"),

        // Tab(text: "Forum"),
        if (d!.certified!) const Tab(text: "Certificates"),
        //Tab(text: "Assignments"),
      ],
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 1.2,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCurriculumTab(),
          //_buildForumTab(),
          if (widget.data!.certified!) _buildCertificatesTab(),
          //_buildAssignmentsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "ABOUT COURSE",
              style: TextStyle(
                color: primaryPurple,
                fontSize: 16,
                fontFamily: 'Serif',
              ),
            ),
            TextButton.icon(
              onPressed: () => _showReviewDialog(context),
              icon: const Icon(
                Icons.rate_review_outlined,
                size: 18,
                color: primaryPurple,
              ),
              label: Text(
                "Write Review",
                style: GoogleFonts.montserrat(
                  color: primaryPurple,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(widget.data!.description!),
        widget.data!.about != null ? Text(widget.data!.about!) : Text(''),
        /*  _buildNumberedList([
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
          "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
          "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        ]), */
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildNumberedList(List<String> items) {
    return Column(
      children: items.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${entry.key + 1}. ",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Expanded(
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccordionItem(
    String title,
    String answer, {
    bool isOpen = false,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontFamily: 'Serif',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: isOpen ? primaryPurple : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
          crossFadeState: isOpen
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
        Divider(height: 24, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _buildCurriculumTab() {
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
            color: primaryPurple,
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
                color: primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...modules.map((m) {
          bool isDone = m['status'] == 'done';
          bool isActive = m['status'] == 'active';

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
                    color: primaryPurple,
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

  Widget _buildCertificatesTab() {
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
                  color: primaryPurple,
                  size: 18,
                ),
                label: const Text(
                  "Download",
                  style: TextStyle(color: primaryPurple),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedStars = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Write a Review",
                style: TextStyle(
                  fontFamily: 'Serif',
                  color: primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedStars
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedStars = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "What did you think of this course?",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryPurple),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Review submitted successfully!"),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
