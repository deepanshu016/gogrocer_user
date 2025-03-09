import 'dart:io';

import 'package:flutter/foundation.dart';

class CurrentUser {
  int? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? password;
  String? rememberToken;
  String? userPhone;
  String? deviceId;
  String? userImage;
  int? userCity;
  int? userArea;
  String? otpValue;
  int? status;
  double? wallet;
  int? rewards;
  int? isVerified;
  int? block;
  String? regDate;
  int? appUpdate;
  String? facebookId;
  String? referralCode;
  int? membership;
  String? memPlanStart;
  String? memPlanExpiry;
  String? createdAt;
  String? updatedAt;
  String? token;
  String? fbId;
  File? userImageFile;
  String? appleId;
  int? totalOrders;
  double? totalSpend;
  double? totalSaved;



  CurrentUser();

  CurrentUser.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'] != null ? int.parse('${json['id']}') : null;
      name = json['name'];
      email = json['email'];
      emailVerifiedAt = json['email_verified_at'];
      password = json['password'];
      rememberToken = json['remember_token'];
      userPhone = json['user_phone'];
      deviceId = json['device_id'];
      userImage = (json['user_image'] != null && '${json['user_image']}' !='N/A') ? json['user_image'] : null;
      userCity = json['user_city'] != null ? int.parse(json['user_city'].toString()) : null;
      userArea = json['user_area'] != null ? int.parse(json['user_area'].toString()) : null;
      otpValue = json['otp_value'];
      status = json['status'] != null ? int.parse('${json['status']}') : null;
      wallet = json['wallet'] != null ? double.parse('${json['wallet']}') : null;
      rewards = json['rewards'] != null ? int.parse('${json['rewards']}') : null;
      isVerified = json['is_verified'] != null ? int.parse('${json['is_verified']}') : null;
      block = json['block'] != null ? int.parse('${json['block']}') : null;
      regDate = json['reg_date'];
      appUpdate = json['app_update'] != null ? int.parse('${json['app_update']}') : null;
      facebookId = json['facebook_id'];
      referralCode = json['referral_code'];
      membership = json['membership'] != null ? int.parse('${json['membership']}') : null;
      memPlanStart = json['mem_plan_start'];
      memPlanExpiry = json['mem_plan_expiry'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
      token = json['token'];
      totalOrders = json['total_orders'] != null ? int.parse('${json['total_orders']}') : null;
      totalSpend = json['total_spent'] != null ? double.parse('${json['total_spent']}') : null;
      totalSaved = json['total_save'] != null ? double.parse('${json['total_save']}') : null;
    } catch (e) {
      debugPrint("Exception - user_model.dart - User.fromJson():$e");
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'email_verified_at': emailVerifiedAt,
        'password': password,
        'remember_token': rememberToken,
        'user_phone': userPhone,
        'device_id': deviceId,
        'user_image': userImage,
        'user_city': userCity,
        'user_area': userArea,
        'otp_value': otpValue,
        'status': status,
        'wallet': wallet,
        'rewards': rewards,
        'is_verified': isVerified,
        'block': block,
        'reg_date': regDate,
        'app_update': appUpdate,
        'facebook_id': facebookId,
        'referral_code': referralCode,
        'membership': membership,
        'mem_plan_start': memPlanStart,
        'mem_plan_expiry': memPlanExpiry,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'token': token,
      };

  @override
  String toString() {
    return 'CurrentUser{id: $id, name: $name, email: $email, emailVerifiedAt: $emailVerifiedAt, password: $password, rememberToken: $rememberToken, userPhone: $userPhone, deviceId: $deviceId, userImage: $userImage, userCity: $userCity, userArea: $userArea, otpValue: $otpValue, status: $status, wallet: $wallet, rewards: $rewards, isVerified: $isVerified, block: $block, regDate: $regDate, appUpdate: $appUpdate, facebookId: $facebookId, referralCode: $referralCode, membership: $membership, memPlanStart: $memPlanStart, memPlanExpiry: $memPlanExpiry, createdAt: $createdAt, updatedAt: $updatedAt, token: $token, fbId: $fbId, userImageFile: $userImageFile, appleId: $appleId, totalOrders: $totalOrders, totalSpend: $totalSpend, totalSaved: $totalSaved}';
  }
}
