import 'package:app/models/qna.dart';
import 'package:app/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Qna {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();

  Future<List<QnaData>> list(String courseid) async {
    List<QnaData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { questions(filter: $filter) { count rows { id type title description status options { id title sort } } } }',
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
      dynamic rows = result?['data']?['questions']?['rows'];
      for (var row in rows) {
        data.add(QnaData.fromJson(row));
      }
    }
    return data;
  }
}
