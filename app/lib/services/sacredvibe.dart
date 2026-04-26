import 'package:app/models/sacredvibe.dart';
import 'package:app/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Sacredvibe {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();

  Future<List<SacredvibeData>> list() async {
    List<SacredvibeData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { sacredvibes(filter: $filter) { count rows { id title url duration } } }',
      "variables": {"filter": {}},
    };

    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['sacredvibes']?['rows'];
      for (var row in rows) {
        data.add(
          SacredvibeData(
            id: row['id'],
            title: row['title'],
            url: row['url'],
            duration: row['ducation'],
          ),
        );
      }
    }
    return data;
  }
}
