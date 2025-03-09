import 'package:flutter/foundation.dart';

class PaypalMethod{
  String? paypalStatus;
  String? paypalClientId;
  String? paypalSecret;

   PaypalMethod();

  PaypalMethod.fromJson(Map<String, dynamic> json) {
    try {
      paypalStatus = json['paypal_status'];
      paypalClientId = json['paypal_client_id'];
      paypalSecret = json['paypal_secret'];
    } catch (e) {
      debugPrint("Exception - PaypalModel.dart - PaypalMethod.fromJson():$e");
    }
  }
}