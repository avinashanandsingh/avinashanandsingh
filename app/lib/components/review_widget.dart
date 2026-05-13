import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class ReviewWidget extends StatelessWidget {
  const ReviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ReviewSummary(
          averageRating: 4.5,
          totalReviews: 273,
          ratingDistribution: {5: 0.9, 4: 0.7, 3: 0.5, 2: 0.3, 1: 0.1},
        ),
        const SizedBox(height: 32),
        const ReviewItem(
          name: 'Jason Smith',
          rating: 4,
          date: '20 Feb 2022',
          review:
              'This course definitely brings me more values than I expect. Thank you so much both of you guys!',
        ),
        const Divider(height: 32),
        const ReviewItem(
          name: 'Wilson Armela',
          rating: 4,
          date: '20 Feb 2022',
          review:
              'Super helpful class! I\'m on my way to create a Digital Marketing Agency and I have found plenty of value inside this course. Highly recommend!',
        ),
        const Divider(height: 32),
        const ReviewItem(
          name: 'Ajax Simpson',
          rating: 4,
          date: '20 Feb 2022',
          review: 'This class exceeded my expectations!',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
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
  final String name;
  final int rating;
  final String date;
  final String review;

  const ReviewItem({
    super.key,
    required this.name,
    required this.rating,
    required this.date,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
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
                  index < rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 24,
                );
              }),
            ),
            Text(
              date,
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
          review,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.black87.withOpacity(0.7),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
