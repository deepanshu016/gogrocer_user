import 'package:flutter/foundation.dart';

class RazorpayMethod {
  String? razorpayStatus;
  String? razorpaySecret;
  String? razorpayKey;
  RazorpayMethod();

  RazorpayMethod.fromJson(Map<String, dynamic> json) {
    try {
      razorpayStatus = json['razorpay_status'];
      razorpaySecret = json['razorpay_secret'];
      razorpayKey = json['razorpay_key'];
    } catch (e) {
      debugPrint("Exception - razorpay_model.dart - RazorpayMethod.fromJson():$e");
    }
  }
}
