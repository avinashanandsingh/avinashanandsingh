import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';

import '../../models/module.dart';
import '../../services/service.dart';
import '../../components/video_player_dialog.dart' as video_dialog;

class Curriculum extends StatelessWidget {
  final List<ModuleData> list;
  final bool? enrolled;
  const Curriculum({super.key, required this.list, this.enrolled});

  @override
  Widget build(BuildContext context) {
    int total = list.length;
    int done = 0;
    if (list.isNotEmpty) {
      done = 0; // list.where((x) => x.completed == true).toList().length;
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text(
          "${list.length} MODULES",
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
          children: [
            Text(
              "$done/$total Done",
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "0%",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (list.isNotEmpty) ...[
          ...list.map((m) {
            bool isDone = false;
            return GestureDetector(
              onTap: () async {
                var enrolled = await Service.course.isEnrolled(m.courseId!);
                if (enrolled) {
                  video_dialog.show(
                    context,
                    url: m.url!,
                    trackingEnable: true,
                    moduleId: m.id,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  children: [
                    if (enrolled == true)
                      // ignore: dead_code
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.purple,
                        child: Icon(
                          Icons.lock_open_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.purple,
                        child: Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),

                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        m.title!,
                        style: TextTheme.of(context).labelSmall!.copyWith(
                          color: isDone ? Colors.grey : Colors.black87,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Text(
                      m.duration!,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
