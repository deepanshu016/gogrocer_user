import 'package:flutter/foundation.dart';

class PayStackMethod {
  String? paystackStatus;
  String? paystackPublicKey;
  String? paystackSeckeyKey;
  PayStackMethod();

  PayStackMethod.fromJson(Map<String, dynamic> json) {
    try {
      paystackStatus = json['paystack_status'];
      paystackPublicKey = json['paystack_public_key'];
      paystackSeckeyKey = json['paystack_secret_key'];
    } catch (e) {
      debugPrint("Exception - pay_stack_model.dart - PayStackMethod.fromJson():$e");
    }
  }
}
