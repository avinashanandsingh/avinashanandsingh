import 'package:app/models/short.dart';
import 'package:app/services/api.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Short {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();
  //static final Course instance = Course._init();

  // Singleton instance
  //Course._init();

  Future<Result<ShortData>> list() async {
    Result<ShortData> out = Result<ShortData>(succeed: false);
    List<ShortData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { shorts(filter: $filter) { count rows { id title description url likes dislikes hits } } }',
      "variables": {"filter": {}},
    };

    dynamic result = await api.post(url, body);
    if (result['errors'] != null) {
      dynamic error = result!['errors']![0];
      String msg =
          error?['extensions']?['originalError']?['message'] ??
          error?['message'];
      out.succeed = false;
      out.message = msg;
    } else {
      dynamic rows = result?['data']['shorts']?['rows'];
      for (var row in rows) {
        data.add(ShortData.fromJson(row));
      }
      out.succeed = true;
      out.data = data;
    }

    return out;
  }
}
