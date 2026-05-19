import 'package:app/models/course.dart';
import 'package:app/models/enroll.dart';
import 'package:app/services/api.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Enrollment {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();
  Future<List<EnrollData>> list(dynamic filter) async {
    //print('called ${filter?.toJson()}');
    List<EnrollData> data = [];
    dynamic body = {
      "query":
          'query list (\$filter: Filter!) { courses(filter: \$filter) { count rows { id title description about duration validity thumbnail url certified short level free currency price offer status review modules { id } } } }',
      "variables": {"filter": filter},
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['courses']?['rows'];
      for (var row in rows) {
        data.add(EnrollData.fromJson(row));
      }
    }
    return data;
  }

  Future<EnrollData?> get(Map<String, dynamic> filter) async {
    EnrollData? data;
    dynamic body = {
      "query":
          r'query get ($filter: Filter!) { course(filter: $filter) { id title description about duration validity thumbnail url certified short level free currency price offer status review modules { id } } }',
      "variables": {"filter": filter},
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic row = result?['data']['course'];
      data = EnrollData.fromJson(row);
    }
    return data;
  }

  Future<bool> isEnrolled(String courseId) async {
    bool flag = false;
    dynamic me = await Service.identity.me();
    dynamic body = {
      "query":
          r'query isEnrolled ($courseId: UUID!) { isEnrolled(courseId: $courseId) { courseid scheduleid userid } }',
      "variables": {"courseId": courseId},
    };

    if (me != null) {
      body = {
        "query":
            r'query isEnrolled ($courseId: UUID!, $userId: UUID) { isEnrolled(courseId: $courseId, userId: $userId) { courseid scheduleid userid } }',
        "variables": {"courseId": courseId, "userId": me["id"]},
      };
    }
    dynamic result = await api.post(url, body);
    if (result != null) {
      flag = (result['errors'] == null);
    }
    return flag;
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
