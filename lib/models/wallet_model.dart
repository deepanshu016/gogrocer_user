import 'package:flutter/foundation.dart';

class Wallet {
  int? walletRechargeHistory;
  int? userId;
  String? rechargeStatus;
  int? amount;
  String? paymentGateway;
  String? dateOfRecharge;
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? password;
  dynamic rememberToken;
  String? userPhone;
  String? deviceId;
  String? userImage;
  int? userCity;
  int? userArea;
  String? otpValue;
  int? status;
  int? wallet;
  int? rewards;
  int? isVerified;
  int? block;
  DateTime? regDate;
  int? appUpdate;
  dynamic facebookId;
  String? referralCode;
  int? membership;
  DateTime? memPlanStart;
  DateTime? memPlanExpiry;
  dynamic createdAt;
  DateTime? updatedAt;
  String? cartId;
  int? paidbywallet;
  String? deliveryDate;

  Wallet();

  Wallet.fromJson(Map<String, dynamic> json) {
    try {
      cartId = json["cart_id"];
      walletRechargeHistory = json["wallet_recharge_history"] != null ? int.parse(json["wallet_recharge_history"].toString()) : null;
      userId = json["user_id"] != null ? int.parse(json["user_id"].toString()) : null;
      rechargeStatus = json["recharge_status"];
      amount = json["amount"] != null ? double.parse(json["amount"].toString()).round() : null;
      paidbywallet = json["paid_by_wallet"] != null ? double.parse(json["paid_by_wallet"].toString()).round() : null;
      paymentGateway = json["payment_gateway"];
      id = json["id"] != null ? int.parse(json["id"].toString()) : null;
      name = json["name"];
      email = json["email"];
      emailVerifiedAt = json["email_verified_at"];
      password = json["password"];
      rememberToken = json["remember_token"];
      userPhone = json["user_phone"];
      deviceId = json["device_id"];
      userImage = json["user_image"];
      userCity = json["user_city"] != null ? int.parse(json["user_city"].toString()) : null;
      userArea = json["user_area"] != null ? int.parse(json["user_area"].toString()) : null;
      otpValue = json["otp_value"];
      status = json["status"] != null ? int.parse(json["status"].toString()) : null;
      wallet = json["wallet"] != null ? double.parse(json["wallet"].toString()).round() : null;
      rewards = json["rewards"] != null ? int.parse(json["rewards"].toString()) : null;
      isVerified = json["is_verified"];
      block = json["block"];
      appUpdate = json["app_update"] != null ? int.parse(json["app_update"].toString()) : null;
      facebookId = json["facebook_id"];
      referralCode = json["referral_code"];
      membership = json["membership"] != null ? int.parse(json["membership"].toString()) : null;
      regDate = json["reg_date"] != null ? DateTime.parse(json["reg_date"]) : null;
      createdAt = json["created_at"] != null ? DateTime.parse(json["created_at"]) : null;
      updatedAt = json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null;
      dateOfRecharge = json["date_of_recharge"];
      memPlanStart = json["mem_plan_start"] != null ? DateTime.parse(json["mem_plan_start"]) : null;
      memPlanExpiry = json["mem_plan_expiry"] != null ? DateTime.parse(json["mem_plan_expiry"]) : null;
      deliveryDate = json["delivery_date"];
    } catch (e) {
      debugPrint("Exception - wallet_model.dart - Wallet.fromJson():$e");
    }
  }
}
