import 'package:app/models/aura.dart';
import 'package:app/models/common.dart';
import 'package:app/models/geo.dart';
import 'package:app/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Common {
  final String url = dotenv.env['URL'] ?? '';
  final ApiService api = ApiService();

  Future<List<EnumData>> enumList(String name) async {
    List<EnumData> data = [];
    dynamic body = {
      "query":
          r'query list ($name: String!) { enums (name: $name) { name value } }',
      "variables": {"name": name},
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['enums'];
      for (var row in rows) {
        data.add(EnumData.fromJson(row));
      }
    }
    return data;
  }

  Future<List<CountryData>> countryList() async {
    List<CountryData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!){ countries(filter: $filter){ count rows { id name } } }',
      "variables": {"filter": {}},
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['countries']?['rows'];
      for (var row in rows) {
        data.add(CountryData.fromJson(row));
      }
    }
    return data;
  }

  Future<List<StateData>> stateList(int countryId) async {
    List<StateData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!){ states(filter: $filter){ count rows { id name } } }',
      "variables": {
        "filter": {
          "criteria": [
            {"column": "countryid", "cop": "eq", "value": countryId},
          ],
        },
      },
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['states']?['rows'];
      for (var row in rows) {
        data.add(StateData.fromJson(row));
      }
    }
    return data;
  }

  Future<List<CityData>> cityList(int countryId, int? stateId) async {
    List<CityData> data = [];
    dynamic body = {
      "query":
          r'query list ($filter: Filter!){ cities(filter: $filter){ count rows { id name } } }',
      "variables": {
        "filter": {
          "criteria": [
            {"column": "countryid", "cop": "eq", "value": countryId},
            if (stateId != null)
              {
                "column": "stateid",
                "cop": "eq",
                "lop": "AND",
                "value": stateId,
              },
          ],
        },
      },
    };
    dynamic result = await api.post(url, body);
    if (result != null) {
      dynamic rows = result?['data']['cities']?['rows'];
      for (var row in rows) {
        data.add(CityData.fromJson(row));
      }
    }
    return data;
  }
}
