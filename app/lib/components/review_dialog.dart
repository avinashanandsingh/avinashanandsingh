import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void show(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ReviewDialog();
    },
  );
}

class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key});

  @override
  State<ReviewDialog> createState() => ReviewDialogState();
}

class ReviewDialogState extends State<ReviewDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int selectedStars = 0;
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            "Write a Review",
            style: GoogleFonts.montserrat(
              color: AppColors.primary,
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
                      index < selectedStars ? Icons.star : Icons.star_border,
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
                    borderSide: const BorderSide(color: AppColors.primary),
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
                  fontSize: 16,
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text("Submit", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
