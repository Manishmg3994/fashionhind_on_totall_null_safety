import 'dart:async';
import 'package:fashionhind/data_model/currency_response.dart';
import 'package:fashionhind/helpers/system_config.dart';
import 'package:fashionhind/helpers/shared_value_helper.dart';
import 'package:fashionhind/repositories/cart_repository.dart';
import 'package:fashionhind/repositories/currency_repository.dart';
import 'package:flutter/material.dart';

class CurrencyPresenter extends ChangeNotifier {
  List<CurrencyInfo> currencyList = [];

  fetchListData() async {
    currencyList.clear();
    var res = await CurrencyRepository().getListResponse();
    print("res.data ${system_currency.$}");
    print(res.data.toString());
    currencyList.addAll(res.data!);

    currencyList.forEach((element) {
      if (element.isDefault!) {
        SystemConfig.defaultCurrency = element;
      }
      if (system_currency.$ == null && element.isDefault!) {
        SystemConfig.systemCurrency = element;
        system_currency.$ = element.id!;
        system_currency.save();
      }
      if (system_currency.$ != null && element.id == system_currency.$) {
        SystemConfig.systemCurrency = element;
        system_currency.$ = element.id!;
        system_currency.save();
      }
    });
    notifyListeners();
  }
}
