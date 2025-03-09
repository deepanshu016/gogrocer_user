import 'package:flutter/foundation.dart';

class StripeMethod {
  String? stripeStatus;
  String? stripSecret;
  String? stripePublishable;
  String? stripeMerchantId;

  StripeMethod();

  StripeMethod.fromJson(Map<String, dynamic> json) {
    try {
      stripeStatus = json['stripe_status'];
      stripSecret = json['stripe_secret'];
      stripePublishable = json['stripe_publishable'];
      stripeMerchantId = json['stripe_merchant_id'];
    } catch (e) {
      debugPrint("Exception - stripe_pay_model.dart - StripeMethod.fromJson():$e");
    }
  }
}
