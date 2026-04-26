import 'package:app/models/short.dart';
import 'package:app/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Short {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();
  //static final Course instance = Course._init();

  // Singleton instance
  //Course._init();

  Future<List<ShortData>> list() async {
    List<ShortData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { shorts(filter: $filter) { count rows { id title thumbnail url likes hits } } }',
      "variables": {"filter": {}},
    };

    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['shorts']?['rows'];
      for (var row in rows) {
        data.add(
          ShortData(
            id: row['id'],
            title: row['title'],
            thumbnail: row['thumbnail'],
            url: row['url'],
            likes: row['likes'],
            hits: row['hits'],
          ),
        );
      }
    }
    return data;
  }
}
