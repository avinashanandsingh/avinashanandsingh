import 'package:app/models/review.dart';
import 'package:app/services/api.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Review {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();

  Future<Result<ReviewData>> list(dynamic filter) async {
    List<ReviewData> data = [];
    Result<ReviewData> out = Result(succeed: false);
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { reviews(filter: $filter) { count rows { id context contextid userid user {id avatar first_name last_name} rating context public createdat } } }',
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
      dynamic rows = result?['data']['reviews']?['rows'];
      if (rows != null) {
        out.succeed = true;
        for (var row in rows) {
          data.add(ReviewData.fromJson(row));
        }
        out.list = data;
      } else {
        out.list = [];
      }
    }

    return out;
  }

  Future<Result<ReviewData>> get(dynamic filter) async {
    Result<ReviewData> out = Result(succeed: false);
    dynamic body = {
      "query":
          r'query get ($filter: Filter!) { review(filter: $filter) { id context contextid userid user {id avatar first_name last_name} rating context public createdat  } }',
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
      dynamic data = result?['data']['review'];
      out.succeed = true;
      out.row = ReviewData.fromJson(data);
    }
    return out;
  }

  Future<Result<ReviewSummaryData>> summary(
    String context,
    String contextId,
  ) async {
    Result<ReviewSummaryData> out = Result(succeed: false);
    dynamic body = {
      "query":
          r'query get ($context: Context!, $contextId: UUID!) { reviewSummary(context: $context, contextId: $contextId) { context contextid reviews average r1 r2 r3 r4 r5 } }',
      "variables": {"context": context, "contextId": contextId},
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
      dynamic data = result?['data']['reviewSummary'];
      out.succeed = true;
      out.row = ReviewSummaryData.fromJson(data);
    }
    return out;
  }

  Future<dynamic> post(
    String context,
    String contextId,
    int rating,
    String content,
  ) async {
    dynamic body = {
      "query":
          r'mutation add ($input: ReviewIn!) { postReview(input: $input) { id } }',
      "variables": {
        "input": {
          "context": context,
          "contextid": contextId,
          "rating": rating,
          "content": content,
        },
      },
    };
    return await api.post(url, body);
  }
}
