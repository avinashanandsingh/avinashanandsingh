import 'package:app/components/loader.dart';
import 'package:app/models/course.dart';
import 'package:app/services/service.dart';
import 'package:app/theme/theme.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/helpers/globals.dart';

void show(BuildContext context, dynamic ref) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ReviewDialog(ref: ref);
    },
  );
}

class ReviewDialog extends StatefulWidget {
  final dynamic ref;
  const ReviewDialog({super.key, this.ref});

  @override
  State<ReviewDialog> createState() => ReviewDialogState();
}

class ReviewDialogState extends State<ReviewDialog> {
  String? content;
  int rating = 0;
  @override
  void initState() {
    super.initState();
    content = '';
    rating = 0;

    print(widget.ref.toString());
  }

  @override
  Widget build(BuildContext context) {
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
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),

              TextField(
                maxLines: 4,
                style: TextTheme.of(context).labelSmall,
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
                onChanged: (value) {
                  setState(() {
                    content = value;
                  });
                },
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
              onPressed: () async {
                dynamic result;
                if (widget.ref is CourseData) {
                  Loader.show();
                  result = await Service.review.post(
                    'COURSE',
                    widget.ref?.id,
                    rating,
                    content!,
                  );
                  Loader.hide();
                  if (result?['errors'] == null) {
                    Navigator.pop(context);
                    Alert.show(
                      "Review submitted successfully!",
                      isError: false,
                    );
                  } else {
                    dynamic error = result!['errors']![0];
                    String msg =
                        error?['extensions']?['originalError']?['message'] ??
                        error?['message'];
                    Alert.show(msg, isError: true);
                  }
                }
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
