import 'package:app/models/reaction.dart';
import 'package:app/models/resource.dart';
import 'package:app/services/api.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Reaction {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();

  Future<Result<ReactionData>> list(dynamic filter) async {
    List<ReactionData> data = [];
    Result<ReactionData> out = Result(succeed: false);
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
    if (result['errors'] != null) {
      dynamic error = result!['errors']![0];
      String msg =
          error?['extensions']?['originalError']?['message'] ??
          error?['message'];
      out.succeed = false;
      out.message = msg;
    } else {
      dynamic rows = result?['data']['resources']?['rows'];
      for (var row in rows) {
        data.add(ReactionData.fromJson(row));
      }
      out.succeed = true;
      out.list = data;
    }

    return out;
  }

  Future<Result<ReactionData>> get(dynamic filter) async {
    ReactionData? row;
    Result<ReactionData> out = Result(succeed: false);
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { resource(filter: $filter) { id type userid context contextid  } }',
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
      dynamic data = result?['data']['resource'];
      row = ReactionData.fromJson(data);
      out.succeed = true;
      out.row = row;
    }
    return out;
  }

  Future<Result> like(String context, String contextId) async {
    Result out = Result(succeed: false);
    dynamic body = {
      "query":
          r'mutation add ($input: ReactionIn!) { newReaction(input: $input) { id } }',
      "variables": {
        "input": {"context": context, "contextid": contextId, "type": "LIKE"},
      },
    };

    dynamic result = await api.post(url, body);
    if (result == null) {
      out.succeed = false;
      out.message = "Unable to perform like operation";
      return out;
    }
    if (result['errors'] != null) {
      dynamic error = result!['errors']![0];
      String msg =
          error?['extensions']?['originalError']?['message'] ??
          error?['message'];
      out.succeed = false;
      out.message = msg;
    } else {
      dynamic id = result?['data']?['newReaction']?['id'];
      out.id = id;
      out.succeed = true;
    }
    return out;
  }

  Future<Result> dislike(String context, String contextId) async {
    Result out = Result(succeed: false);
    dynamic body = {
      "query":
          r'mutation add ($input: ReactionIn!) { newReaction(input: $input) { id } }',
      "variables": {
        "input": {
          "type": "DISLIKE",
          "context": context,
          "contextid": contextId,
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
      dynamic id = result?['data']['newReaction']['id'];
      out.id = id;
      out.succeed = true;
    }
    return out;
  }
}
