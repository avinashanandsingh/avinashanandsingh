import 'package:app/models/profile.dart';
import 'package:app/services/api.dart';
import 'package:app/services/storage.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class User {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();
  final Storage store = Storage();
  // Verify user is logged in
  Future<ProfileData?> me() async {
    String? token = await store.get("token");
    if (token != null) {
      dynamic user = JwtDecoder.decode(token);
      String id = user["id"];
      dynamic body = {
        "query":
            r'query get ($id: UUID!) { user (id: $id) { id avatar about first_name last_name gender dob address countryid country { id name } stateid state { id name } cityid city {id name } postal_code email phone profession income referby { id first_name last_name email } last_login_at } }',
        "variables": {"id": id},
      };

      dynamic result = await api.post(url, body);

      if (result['errors'] == null) {
        dynamic row = result['data']['user'];
        return ProfileData.fromJson(row);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<dynamic> update(ProfileData entity) async {
    dynamic result;
    dynamic data = entity.toJson();
    data.removeWhere((key, value) => value == null);
    data.remove('id');
    data.remove('last_login_at');
    dynamic body = {
      "query":
          r'mutation update ($id: UUID!, $input: ProfileIn!) { updateProfile (id: $id, input: $input) { id } }',
      "variables": {"id": entity.id, "input": data},
    };
    try {
      result = await api.post(url, body);
    } catch (e) {
      return null;
    }
    return result;
  }

  Future<dynamic> delete(String id) async {
    dynamic body = {
      "query": 'mutation delete (\$id: UUID!) { deleteUser (id: \$id) { id } }',
      "variables": {"id": id},
    };
    return await api.post(url, body);
  }
}
