import 'package:fashionhind/app_config.dart';
import 'package:fashionhind/data_model/addons_response.dart';
import 'package:fashionhind/data_model/offline_wallet_recharge_response.dart';
import 'package:http/http.dart' as http;

class AddonsRepository {
  Future<List<AddonsListResponse>> getAddonsListResponse() async {
    $();
    Uri url = Uri.parse('${AppConfig.BASE_URL}/addon-list');

    final response = await http.get(url);
    //print("adons ${response.body}");

    return addonsListResponseFromJson(response.body);
  }
}
