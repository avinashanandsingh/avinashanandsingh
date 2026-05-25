import 'package:app/helpers/convert.dart';
import 'package:app/models/filter.dart';
import 'package:app/models/review.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class ReviewWidget extends StatefulWidget {
  final String id;
  final String type;
  const ReviewWidget({super.key, required this.type, required this.id});

  @override
  State<ReviewWidget> createState() => ReviewState();
}

class ReviewState extends State<ReviewWidget> {
  List<ReviewData> list = List.empty(growable: true);

  final ScrollController scroller = ScrollController();
  int page = 1;
  int offset = 0;
  int limit = 5;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData(); // Initial load
    scroller.addListener(() {
      // Check if user is at the bottom
      if (scroller.position.pixels >= scroller.position.maxScrollExtent &&
          !isLoading) {
        fetchData();
      }
    });
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    // Simulate API call

    var result = await Service.review.list({
      "criteria": [
        {"column": "context", "cop": "eq", "value": widget.type},
        {"column": "contextid", "cop": "eq", "lop": "AND", "value": widget.id},
      ],
      "offset": offset,
      "limit": limit,
    });
    if (result.succeed) {
      setState(() {
        list.addAll(result.list!);
        page++;
        offset = (page - 1) * limit;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder(
          future: Service.review.summary(widget.type, widget.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasData) {
              var result = snapshot.data;
              if (result!.succeed) {
                return ReviewSummary(
                  averageRating: result.row!.average!,
                  totalReviews: result.row!.reviews!,
                  ratingDistribution: {
                    5: Convert.shiftDecimal(result.row!.r5!),
                    4: Convert.shiftDecimal(result.row!.r4!),
                    3: Convert.shiftDecimal(result.row!.r3!),
                    2: Convert.shiftDecimal(result.row!.r2!),
                    1: Convert.shiftDecimal(result.row!.r1!),
                  },
                );
              } else {
                return Container();
              }
            } else {
              return Container();
            }
          },
        ),

        const SizedBox(height: 32),
        SizedBox(
          height: 300,
          child: ListView.builder(
            controller: scroller,
            //shrinkWrap: true,
            //physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == list.length) {
                return Center(
                  child: CircularProgressIndicator(),
                ); // Bottom loader
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReviewItem(data: list[index]),
                  const Divider(height: 32),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              await fetchData();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'View More',
              style: TextTheme.of(
                context,
              ).labelMedium!.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class ReviewSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, double> ratingDistribution;

  const ReviewSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Large rating
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    averageRating.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 32),
                ],
              ),
              Text(
                '$totalReviews Reviews',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        // Right side: Progress bars
        Expanded(
          flex: 3,
          child: Column(
            children: [5, 4, 3, 2, 1].map((stars) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      stars.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratingDistribution[stars] ?? 0,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.amber,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  final ReviewData data;

  const ReviewItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.user!.fullName!,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < data.rating!
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 24,
                );
              }),
            ),
            Text(
              data.postedAt!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          data.content ?? '',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.black87.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
