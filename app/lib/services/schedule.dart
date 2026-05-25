import 'package:app/models/schedule.dart';
import 'package:app/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Schedule {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();

  Future<List<ScheduleData>> list(String courseid) async {
    List<ScheduleData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { schedules(filter: $filter) { count rows { id title start_date end_date start_time end_time } } }',
      "variables": {
        "filter": {
          "criteria": [
            {"column": "status", "cop": "eq", "value": "ACTIVE"},
            {
              "column": "courseid",
              "cop": "eq",
              "lop": "AND",
              "value": courseid,
            },
          ],
        },
      },
    };
    dynamic result = await api.post(url, body);
    if (result?['errors'] == null) {
      dynamic rows = result?['data']?['schedules']?['rows'];
      for (var row in rows) {
        data.add(ScheduleData.fromJson(row));
      }
    }
    return data;
  }

  Future<ScheduleData?> get(dynamic filter) async {
    ScheduleData? data;
    dynamic body = {
      "query":
          r'query get ($filter: Filter!) { schedule(filter: $filter) { id title start_date end_date start_time end_time } }',
      "variables": {"filter": filter},
    };
    dynamic result = await api.post(url, body);
    if (result?['errors'] == null) {
      dynamic row = result?['data']?['schedule'];
      data = ScheduleData.fromJson(row);
    }
    return data;
  }
}
