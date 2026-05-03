import 'package:app/models/course.dart';
import 'package:app/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Course {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();
  Future<List<CourseData>> list(bool short) async {
    //print('called ${filter?.toJson()}');
    List<CourseData> data = [];
    dynamic body = {
      "query":
          'query list (\$filter: Filter!) { courses(filter: \$filter) { count rows { id title description about duration validity thumbnail url certified short level free currency price offer status review modules { id } } } }',
      "variables": {
        "filter": {
          "criteria": [
            {"column": "status", "cop": "eq", "value": "PUBLISHED"},
            if (short)
              {"column": "short", "cop": "eq", "lop": "AND", "value": short},
          ],
        },
      },
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['courses']?['rows'];
      for (var row in rows) {
        data.add(CourseData.fromJson(row));
      }
    }
    return data;
  }

  Future<CourseData?> get(Map<String, dynamic> filter) async {
    CourseData? data;
    dynamic body = {
      "query":
          r'query get ($filter: Filter!) { course(filter: $filter) { id title description about duration validity thumbnail url certified short level free currency price offer status review modules { id } } }',
      "variables": {"filter": filter},
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic row = result?['data']['course'];
      data = CourseData.fromJson(row);
    }
    return data;
  }

  Future<bool> isEnrolled(String courseId) async {
    bool flag = false;
    dynamic body = {
      "query":
          r'query isEnrolled ($courseId: UUID!) { isEnrolled(courseId: $courseId) }',
      "variables": {"courseId": courseId},
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      flag = result?['data']['isEnrolled'] as bool;
    }
    return flag;
  }
}
