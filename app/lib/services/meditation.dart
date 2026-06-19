import 'package:app/models/meditation.dart';
import 'package:app/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Meditation {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();
  Future<List<MeditationData>> list(dynamic filter) async {
    List<MeditationData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { meditations(filter: $filter) { count rows { id title thumbnail url free price offer status } } }',
      "variables": {"filter": filter},
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['meditations']?['rows'];
      for (var row in rows) {
        data.add(MeditationData.fromJson(row));
      }
    }
    return data;
  }
}
