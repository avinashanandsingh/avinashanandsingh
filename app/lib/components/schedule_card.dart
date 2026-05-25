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
    String startDate = DateFormat.yMMMMEEEEd().format(sd);
    String endDate = DateFormat.yMMMMEEEEd().format(ed);
    String startTime = Convert.timeFormat(data.startTime!);
    String endTime = Convert.timeFormat(data.endTime!);
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title!, style: TextTheme.of(context).headlineSmall),

          Row(
            children: [
              Text(
                "Start Date: ",
                style: TextTheme.of(
                  context,
                ).labelSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(startDate, style: TextTheme.of(context).labelSmall),
            ],
          ),
          Row(
            children: [
              Text(
                "End Date: ",
                style: TextTheme.of(
                  context,
                ).labelSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(endDate, style: TextTheme.of(context).labelSmall),
            ],
          ),
          Row(
            children: [
              Text(
                "Time: ",
                style: TextTheme.of(
                  context,
                ).labelSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "$startTime to $endTime",
                style: TextTheme.of(context).labelSmall,
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
