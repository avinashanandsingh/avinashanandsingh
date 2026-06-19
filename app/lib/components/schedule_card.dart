import 'package:app/helpers/convert.dart';
import 'package:app/models/schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleData data;
  const ScheduleCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    DateTime sd = DateTime.parse(data.startDate!);
    DateTime ed = DateTime.parse(data.endDate!);
    String startDate = DateFormat('E, MMM d, yyyy').format(sd);
    String endDate = DateFormat('E, MMM d, yyyy').format(ed);
    String startTime = Convert.timeFormat(data.startTime!);
    String endTime = Convert.timeFormat(data.endTime!);
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.purple.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(data.title!, style: TextTheme.of(context).headlineSmall),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Start Date: ",
                    style: TextTheme.of(context).labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.purple.shade800,
                    ),
                  ),
                  Text(
                    startDate,
                    style: TextTheme.of(
                      context,
                    ).labelSmall?.copyWith(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "End Date: ",
                    style: TextTheme.of(context).labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.purple.shade800,
                    ),
                  ),
                  Text(
                    endDate,
                    style: TextTheme.of(
                      context,
                    ).labelSmall?.copyWith(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Time: ",
                    style: TextTheme.of(context).labelSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.purple.shade800,
                    ),
                  ),
                  Text(
                    "$startTime to $endTime",
                    style: TextTheme.of(
                      context,
                    ).labelSmall?.copyWith(fontSize: 12),
                  ),
                ],
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
      ),
    );
  }
}
