import 'package:app/models/module.dart';
import 'package:app/services/api.dart';
import 'package:app/services/base.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Module implements Query<ModuleData> {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();

  @override
  Future<Result<ModuleData>> list(dynamic filter) async {
    List<ModuleData>? data = [];
    Result<ModuleData> out = Result<ModuleData>(succeed: false);
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { modules(filter: $filter) { count rows { id courseid course { id title } scheduleid schedule { id title } title duration url completed completedat status } } }',
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
      dynamic rows = result?['data']['modules']?['rows'];
      for (var row in rows) {
        data.add(ModuleData.fromJson(row));
      }
      out.succeed = true;
      out.list = data;
    }
    return out;
  }

  @override
  Future<Result<ModuleData>> get(dynamic filter) async {
    Result<ModuleData> out = Result<ModuleData>(succeed: false);
    dynamic body = {
      "query":
          r'query get ($filter: Filter!) { module(filter: $filter) { id courseid course { id title } scheduleid schedule { id title } title duration url completed completedat status } }',
      "variables": {"filter": filter},
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
      dynamic row = result?['data']['module'];
      out.succeed = true;
      out.row = ModuleData.fromJson(row);
    }
    return out;
  }
}
