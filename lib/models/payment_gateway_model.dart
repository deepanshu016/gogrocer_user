
import 'package:flutter/foundation.dart';
import 'package:user/models/paypal_model.dart';
import 'package:user/models/pay_stack_model.dart';
import 'package:user/models/razorpay_model.dart';
import 'package:user/models/stripe_pay_model.dart';

class PaymentGateway {
  RazorpayMethod? razorpay;
  StripeMethod? stripe;
  PayStackMethod? paystack;
  PaypalMethod? paypal;
  PaymentGateway();

  PaymentGateway.fromJson(Map<String, dynamic> json) {
    try {
      razorpay = json['razorpay'] != null ? RazorpayMethod.fromJson(json['razorpay']) : null;
      stripe = json['stripe'] != null ? StripeMethod.fromJson(json['stripe']) : null;
      paystack = json['paystack'] != null ? PayStackMethod.fromJson(json['paystack']) : null;
        paypal = json['paypal'] != null ? PaypalMethod.fromJson(json['paypal']) : null;
    } catch (e) {
      debugPrint("Exception - payment_gateway_model.dart - PaymentGateway.fromJson():$e");
    }
  }
}
