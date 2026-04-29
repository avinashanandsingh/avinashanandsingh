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
          'query list (\$filter: Filter!) { courses(filter: \$filter) { count rows { id title description duration validity thumbnail url certified short level free currency price offer status review } } }',
      "variables": {"filter": {}},
    };
    dynamic result = await api.post(url, body);

    if (result != null) {
      dynamic rows = result?['data']['courses']?['rows'];
      for (var row in rows) {
        if (row['short'] == short) {
          try {
            data.add(CourseData.fromJson(row));
          } catch (e) {
            print(e.toString());
          }
        }
      }
    }

    return data;
  }

  Future<CourseData?> get(String id) async {
    CourseData? data;
    dynamic body = {
      "query":
          r'query get ($id: UUID!) { course(id: \$id) { id title description duration validity thumbnail url certified short level free currency price offer status review } }',
      "variables": {"id": id},
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic row = result?['data']['course'];

      data = CourseData.fromJson(row);
    }
    return data;
  }
}
