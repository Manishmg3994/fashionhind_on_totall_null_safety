import 'package:fashionhind/app_config.dart';
import 'package:fashionhind/data_model/check_response_model.dart';
import 'package:fashionhind/helpers/response_check.dart';
import 'package:http/http.dart' as http;
import 'package:fashionhind/data_model/wallet_balance_response.dart';
import 'package:fashionhind/data_model/wallet_recharge_response.dart';
import 'package:fashionhind/helpers/shared_value_helper.dart';

class WalletRepository {
  Future<dynamic> getBalance() async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/wallet/balance");
    print(url.toString());
    print("Bearer ${access_token.$}");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$,
      },
    );

    bool checkResult = ResponseCheck.apply(response.body);

    print(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return walletBalanceResponseFromJson(response.body);
  }

  Future<dynamic> getRechargeList({int page = 1}) async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/wallet/history?page=${page}");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$,
      },
    );

    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return walletRechargeResponseFromJson(response.body);
  }
}
