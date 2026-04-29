import 'package:app/models/page.dart';
import 'package:app/models/sacredvibe.dart';
import 'package:app/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Page {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();

  Future<PageData?> get(String type) async {
    PageData? data;
    dynamic body = {
      "query":
          r'query get ($filter: Filter!) { page(filter: $filter) {  id title body  } }',
      "variables": {
        "filter": {
          "criteria": [
            {"column": "type", "cop": "eq", "value": type},
          ],
        },
      },
    };

    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic row = result?['data']['page'];
      data = PageData(id: row['id'], title: row['title'], body: row['body']);
    }
    return data;
  }
}
