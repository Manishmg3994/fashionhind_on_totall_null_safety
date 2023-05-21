import 'package:fashionhind/app_config.dart';
import 'package:fashionhind/data_model/addons_response.dart';
import 'package:fashionhind/data_model/currency_response.dart';
import 'package:http/http.dart' as http;

class CurrencyRepository {
  Future<CurrencyResponse> getListResponse() async {
    Uri url = Uri.parse('${AppConfig.BASE_URL}/currencies');

    final response = await http.get(url);
    //print("adons ${response.body}");
    return currencyResponseFromJson(response.body);
  }
}
