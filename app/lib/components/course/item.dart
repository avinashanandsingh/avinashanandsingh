import 'package:app/models/enroll.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnrollItem extends StatelessWidget {
  final EnrollData data;

  const EnrollItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String dated = "";
    if (data.enrolledat != null) {
      dated = DateFormat.yMMMMEEEEd().format(DateTime.parse(data.enrolledat!));
    }
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        border: BoxBorder.all(width: 1, color: Colors.grey.shade100),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      //elevation: 2,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              data.course!.thumbnail!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16), // Spacing between thumbnail and details
          // Right Column: Title, Status, and Date
          Expanded(
            child: SizedBox(
              height: 100, // Matches thumbnail height to align items neatly
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Course Title
                  Text(
                    data.course!.title!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Status and Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          //color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data.status!,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      // Date
                      Text(
                        dated,
                        style: TextStyle(
                          color: Colors.purple[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
