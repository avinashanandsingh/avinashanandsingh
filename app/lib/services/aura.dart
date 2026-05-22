import 'package:app/models/aura.dart';
import 'package:app/services/api.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Aura {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();

  Future<Result<AuraData>> list() async {
    Result<AuraData> out = Result<AuraData>(succeed: false);
    List<AuraData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { services(filter: $filter) { count rows { id name price offer status timeslots { id serviceid name start_time end_time capacity } } } }',
      "variables": {
        "filter": {
          "criteria": [
            {"column": "status", "cop": "eq", "value": "ACTIVE"},
          ],
        },
      },
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
      dynamic rows = result?['data']['services']?['rows'];
      for (var row in rows) {
        data.add(AuraData.fromJson(row));
      }
      out.succeed = true;
      out.list = data;
    }
    return out;
  }
}
