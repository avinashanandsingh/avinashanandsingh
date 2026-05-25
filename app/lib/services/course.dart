import 'package:app/models/course.dart';
import 'package:app/models/user.dart';
import 'package:app/services/api.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Course {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();
  Future<Result<CourseData>> list(dynamic filter) async {
    Result<CourseData> out = Result<CourseData>(succeed: false);
    List<CourseData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { courses(filter: $filter) { count rows { id title description about duration validity thumbnail url certified short level free currency price offer status review schedule modules qna } } }',
      "variables": {"filter": filter},
    };
    dynamic result = await api.post(url, body);
    if (result['errors'] != null) {
      dynamic error = result!['errors']![0];
      String msg =
          error?['extensions']?['originalError']?['message'] ??
          error?['message'];
      out.succeed = false;
      out.message = msg;
    } else {
      dynamic rows = result?['data']['courses']?['rows'];
      for (var row in rows) {
        data.add(CourseData.fromJson(row));
      }
      out.succeed = true;
      out.list = data;
    }
    return out;
  }

  Future<Result<CourseData>?> get(dynamic filter) async {
    Result<CourseData> out = Result<CourseData>(succeed: false);
    dynamic body = {
      "query":
          r'query get ($filter: Filter!) { course(filter: $filter) { id title description about duration validity thumbnail url certified short level free currency price offer status review schedule modules qna } }',
      "variables": {"filter": filter},
    };
    dynamic result = await api.post(url, body);
    if (result['errors'] != null) {
      dynamic error = result!['errors']![0];
      String msg =
          error?['extensions']?['originalError']?['message'] ??
          error?['message'];
      out.succeed = false;
      out.message = msg;
    } else {
      dynamic row = result?['data']['course'];
      out.succeed = true;
      out.row = CourseData.fromJson(row);
    }
    return out;
  }

  Future<bool> isEnrolled(String courseId) async {
    bool flag = false;
    UserData? me = await Service.identity.me();

    if (me != null) {
      dynamic body = {
        "query":
            r'query isEnrolled ($courseId: UUID!, $userId: UUID) { isEnrolled(courseId: $courseId, userId: $userId) { courseid scheduleid userid } }',
        "variables": {"courseId": courseId, "userId": me.id!},
      };

      dynamic result = await api.post(url, body);
      if (result['errors'] == null) {
        flag = (result['data']?['isEnrolled'] != null);
      }
    }
    return flag;
  }
}
