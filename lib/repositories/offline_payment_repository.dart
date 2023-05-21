import 'package:fashionhind/app_config.dart';
import 'package:fashionhind/data_model/check_response_model.dart';
import 'package:fashionhind/helpers/response_check.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fashionhind/data_model/offline_payment_submit_response.dart';

import 'package:fashionhind/helpers/shared_value_helper.dart';
import 'package:flutter/foundation.dart';

class OfflinePaymentRepository {
  Future<dynamic> getOfflinePaymentSubmitResponse(
     {required int order_id,
      required String amount,
      required String name,
      required String trx_id,
      required int photo}) async {
    var post_body = jsonEncode({
      "order_id": "$order_id",
      "amount": "$amount",
      "name": "$name",
      "trx_id": "$trx_id",
      "photo": "$photo",
    });

    Uri url = Uri.parse("${AppConfig.BASE_URL}/offline/payment/submit");

    print(post_body);
    print(url);

    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$
        },
        body: post_body);
    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    // print("hello" + response.body.toString());
    return offlinePaymentSubmitResponseFromJson(response.body);
  }
}
