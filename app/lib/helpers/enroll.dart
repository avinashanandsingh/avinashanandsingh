import 'package:app/models/enroll.dart';
import 'package:app/models/schedule.dart';
import 'package:app/models/user.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/result.dart';
import 'package:intl/intl.dart';

class EnrollHelper {
  static Future<Result> initiate(String courseId, {String? qnaData}) async {
    EnrollData entity = EnrollData(courseId: courseId);
    entity.status = "INITIATED";
    var result = await Service.course.get({
      "criteria": [
        {"column": "id", "cop": "eq", "value": entity.courseId},
      ],
    });

    ScheduleData? schedule = await Service.schedule.get({
      "criteria": [
        {"column": "courseid", "cop": "eq", "value": entity.courseId},
        {"column": "status", "cop": "eq", "lop": "AND", "value": "ACTIVE"},
      ],
    });

    entity.scheduleId = schedule?.id;
    var today = DateTime.now();
    entity.enrolledat = DateFormat("yyyy-MM-dd").format(today);
    if ((result?.row?.validity ?? 0) > 0) {
      var exp = today.add(Duration(days: result?.row?.validity ?? 0));
      entity.expiredat = DateFormat("yyyy-MM-dd").format(exp);
    }
    if (qnaData != null) {
      entity.qna = qnaData;
    }

    return await Service.enrollment.initiate(entity);
  }

  static Future<EnrollData?> isInitiated(String courseId) async {
    ScheduleData? schedule = await Service.schedule.get({
      "criteria": [
        {"column": "courseid", "cop": "eq", "value": courseId},
        {"column": "status", "cop": "eq", "lop": "AND", "value": "ACTIVE"},
      ],
    });
    UserData? user = await Service.identity.me();
    EnrollData? enrollData = await Service.enrollment.get({
      "criteria": [
        {"column": "courseid", "cop": "eq", "value": courseId},
        {"column": "status", "cop": "eq", "lop": "AND", "value": "INITIATED"},
        if (user != null) ...[
          {"column": "userid", "cop": "eq", "lop": "AND", "value": user.id},
        ],
        if (schedule != null) ...[
          {
            "column": "scheduleid",
            "cop": "eq",
            "lop": "AND",
            "value": schedule.id,
          },
        ],
      ],
    });
    return enrollData;
  }

  static Future<Result> enrolled(String id) async {
    return await Service.enrollment.enrolled(id);
  }

  static Future<Result> completed(String id) async {
    return await Service.enrollment.completed(id);
  }
}
