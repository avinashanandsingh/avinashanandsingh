import 'package:app/models/setting.dart';
import 'package:app/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Setting {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();
  //static final Course instance = Course._init();

  // Singleton instance
  //Course._init();

  Future<List<SettingData>> list() async {
    List<SettingData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { settings(filter: $filter) { count rows { id name value } } }',
      "variables": {"filter": {}},
    };

    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['settings']?['rows'];
      for (var row in rows) {
        data.add(
          SettingData(id: row['id'], name: row['name'], value: row['value']),
        );
      }
    }
    return data;
  }

  Future<String?> get(String key) async {
    String? value;
    dynamic body = {
      "query":
          r'query get ($filter: Filter!) { setting (filter: $filter) { id name value } }',
      "variables": {
        "filter": {
          "criteria": [
            {"column": "name", "cop": "eq", "value": key},
          ],
        },
      },
    };

    dynamic result = await api.post(url, body);
    if (result != null) {
      value = result?['data']['setting']['value'];
    }
    return value;
  }
}
