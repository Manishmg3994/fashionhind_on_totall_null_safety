import 'package:fashionhind/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fashionhind/data_model/language_list_response.dart';
import 'package:fashionhind/helpers/shared_value_helper.dart';

class LanguageRepository {
  Future<LanguageListResponse> getLanguageList() async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/languages");
    final response = await http.get(url, headers: {
      "App-Language": app_language.$,
    });
    //print(response.body.toString());
    return languageListResponseFromJson(response.body);
  }
}