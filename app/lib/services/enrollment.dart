import 'package:app/models/enroll.dart';
import 'package:app/services/api.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Enrollment {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();
  Future<Result<EnrollData>> list(dynamic filter) async {
    List<EnrollData> data = [];
    Result<EnrollData> out = Result<EnrollData>(succeed: false);
    dynamic body = {
      "query":
          r'query list ($filter: Filter!) { enrollments(filter: $filter) { count rows { id userid user { id first_name last_name } courseid course { id title description thumbnail } scheduleid schedule { id title }  status enrolledat completedat certificate_issued_at droppedat  notes } } }',
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
      dynamic rows = result?['data']['enrollments']?['rows'];
      for (var row in rows) {
        data.add(EnrollData.fromJson(row));
      }
      out.succeed = true;
      out.list = data;
    }
    return out;
  }

  Future<EnrollData?> get(Map<String, dynamic> filter) async {
    EnrollData? data;
    dynamic body = {
      "query":
          r'query get ($filter: Filter!) { enrollment(filter: $filter) { id userid user { id first_name last_name } courseid course { id title description thumbnail } scheduleid schedule { id title }  status enrolledat completedat certificate_issued_at droppedat  notes } }',
      "variables": {"filter": filter},
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic row = result?['data']['enrollment'];
      data = EnrollData.fromJson(row);
    }
    return data;
  }

  Future<Result> initiate(EnrollData dataIn) async {
    Result out = Result(succeed: false);
    dynamic body = {
      "query":
          r'mutation enroll ($input: EnrollIn!) { enroll(input: $input) { id } }',
      "variables": {"input": dataIn.toJson()},
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
      out.succeed = true;
      out.id = result['data']['enroll']['id'];
    }
    return out;
  }

  Future<Result> enrolled(String id) async {
    Result out = Result(succeed: false);
    dynamic body = {
      "query":
          r'mutation changeStatus ($id: UUID!, $status: EnrollmentStatus!) { changeEnrollmentStatus(id: $id, status: $status) { id } }',
      "variables": {"id": id, "status": 'ENROLLED'},
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
      out.succeed = true;
      out.id = result['data']['changeEnrollmentStatus']['id'];
    }
    return out;
  }

  Future<Result> completed(String id) async {
    Result out = Result(succeed: false);
    dynamic body = {
      "query":
          r'mutation changeStatus ($id: UUID!, $status: EnrollmentStatus!) { changeEnrollmentStatus(id: $id, status: $status) { id } }',
      "variables": {"id": id, "status": 'COMPLETED'},
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
      out.succeed = true;
      out.id = result['data']['changeEnrollmentStatus']['id'];
    }
    return out;
  }
}
