import 'package:app/models/resource.dart';
import 'package:app/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Resource {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();

  Future<List<ResourceData>> list() async {
    List<ResourceData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { resources(filter: $filter) { count rows { id title url } } }',
      "variables": {
        "filter": {
          "criteria": [
            {"column": "status", "cop": "eq", "value": "ACTIVE"},
          ],
        },
      },
    };

    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['resources']?['rows'];
      for (var row in rows) {
        data.add(
          ResourceData(id: row['id'], title: row['title'], url: row['url']),
        );
      }
    }
    return data;
  }
}
