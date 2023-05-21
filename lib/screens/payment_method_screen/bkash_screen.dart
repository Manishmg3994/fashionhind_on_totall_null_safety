import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fashionhind/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'dart:convert';
import 'package:fashionhind/repositories/payment_repository.dart';
import 'package:fashionhind/my_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fashionhind/screens/order_list.dart';
import 'package:fashionhind/screens/wallet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BkashScreen extends StatefulWidget {
  double amount;
  String payment_type;
  String payment_method_key;
  var package_id;

  BkashScreen(
      {Key? key,
      this.amount = 0.00,
      this.payment_type = "",
      this.payment_method_key = "",
      this.package_id = "0"})
      : super(key: key);

  @override
  _BkashScreenState createState() => _BkashScreenState();
}

class _BkashScreenState extends State<BkashScreen> {
  int _combined_order_id = 0;
  bool _order_init = false;
  String _initial_url = "";
  bool _initial_url_fetched = false;

  String _token = "";
  bool showLoading = false;

  WebViewController _webViewController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.payment_type == "cart_payment") {
      createOrder();
    }

    if (widget.payment_type != "cart_payment") {
      // on cart payment need proper order id
      getSetInitialUrl();
    }
  }

  createOrder() async {
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponse(widget.payment_method_key);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    _combined_order_id = orderCreateResponse.combined_order_id;
    _order_init = true;
    setState(() {});

    getSetInitialUrl();
  }

  getSetInitialUrl() async {
    var bkashUrlResponse = await PaymentRepository().getBkashBeginResponse(
        widget.payment_type,
        _combined_order_id,
        widget.package_id,
        widget.amount);

    if (bkashUrlResponse.result == false) {
      ToastComponent.showDialog(bkashUrlResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }
    _token = bkashUrlResponse.token;

    _initial_url = bkashUrlResponse.url;
    _initial_url_fetched = true;

    setState(() {});

    // print(_initial_url);
    // print(_initial_url_fetched);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: buildBody(),
    );
  }

  void getData() {
    var payment_details = '';
    _webViewController
        .evaluateJavascript("document.body.innerText")
        .then((data) {
      var responseJSON = jsonDecode(data);
      if (responseJSON.runtimeType == String) {
        responseJSON = jsonDecode(responseJSON);
      }
      print(data);
      if (responseJSON["result"] == false) {
        Toast.show(responseJSON["message"],
            duration: Toast.lengthLong, gravity: Toast.center);
        Navigator.pop(context);
      } else if (responseJSON["result"] == true) {
        payment_details = responseJSON['payment_details'];
        onPaymentSuccess(responseJSON);
      }
    });
  }

  onPaymentSuccess(payment_details) async {
    showLoading = true;
    setState(() {});

    var bkashPaymentProcessResponse =
        await PaymentRepository().getBkashPaymentProcessResponse(
      amount: widget.amount,
      token: _token,
      payment_type: widget.payment_type,
      combined_order_id: _combined_order_id,
      package_id: widget.package_id,
      payment_id: payment_details['paymentID'],
    );

    if (bkashPaymentProcessResponse.result == false) {
      Toast.show(bkashPaymentProcessResponse.message,
          duration: Toast.lengthLong, gravity: Toast.center);
      Navigator.pop(context);
      return;
    }

    Toast.show(bkashPaymentProcessResponse.message,
        duration: Toast.lengthLong, gravity: Toast.center);
    if (widget.payment_type == "cart_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return OrderList(from_checkout: true);
      }));
    } else if (widget.payment_type == "wallet_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Wallet(from_recharge: true);
      }));
    }
  }

  buildBody() {
    if (_order_init == false &&
        _combined_order_id == 0 &&
        widget.payment_type == "cart_payment") {
      return Container(
        child: Center(
          child: Text(AppLocalizations.of(context)!.common_creating_order),
        ),
      );
    } else if (_initial_url_fetched == false) {
      return Container(
        child: Center(
          child: Text(
              AppLocalizations.of(context)!.bkash_screen_fetching_bkash_url),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: showLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 1,
                      height: 1,
                    ),
                    CircularProgressIndicator(
                      strokeWidth: 3,
                    )
                  ],
                )
              : WebView(
                  debuggingEnabled: false,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                    _webViewController.loadUrl(_initial_url);
                  },
                  onWebResourceError: (error) {},
                  onPageFinished: (page) {
                    print(page.toString());
                    print(page.contains("/bkash/api/callback"));

                    if (page.contains("/bkash/api/callback")) {
                      getData();
                    } else if (page.contains("/bkash/api/fail")) {
                      ToastComponent.showDialog("Payment cancelled",
                          gravity: Toast.center, duration: Toast.lengthLong);
                      Navigator.of(context).pop();
                      return;
                    }
                  },
                ),
        ),
      );
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        AppLocalizations.of(context)!.bkash_screen_pay_with_bkash,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
