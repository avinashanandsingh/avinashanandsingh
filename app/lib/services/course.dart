import 'package:app/models/course.dart';
import 'package:app/services/api.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';

class Course {
  final String _url = "http://localhost:3010";
  static final Course instance = Course._init();

  // Singleton instance
  Course._init();

  Future<List<CourseData>> list() async {
    List<CourseData> data = [];
    dynamic body = {
      "query":
          'query list (\$filter: Filter!) { courses(filter: \$filter) { count rows { id title description thumbnail url short level free currency price offer status } } }',
      "variables": {"filter": {}},
    };

    dynamic result = await ApiService.instance.post(_url, body);
    if (result) {
      data = result?['data']?['rows']!;
      print(data);
    }
    print(data);
    return data;
  }
}
