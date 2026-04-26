import 'package:app/models/branding.dart';
import 'package:app/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Branding {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();
  //static final Course instance = Course._init();

  // Singleton instance
  //Course._init();

  Future<List<BrandingData>> list() async {
    List<BrandingData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { brandings(filter: $filter) { count rows { id type title content url } } }',
      "variables": {"filter": {}},
    };

    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['brandings']?['rows'];
      for (var row in rows) {
        data.add(
          BrandingData(
            id: row['id'],
            type: row['type'],
            title: row['title'],
            content: row['content'],
            url: row['url'],
          ),
        );
      }
    }
    //print(data);
    return data;
  }
}
