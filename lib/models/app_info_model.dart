import 'package:flutter/foundation.dart';

class AppInfo {
  String? status;
  String? message;
  int? lastLoc;
  int? phoneNumberLength;
  String? appName;
  String? appLogo;
  String? firebase;
  int? countryCode;
  String? firebaseIso;
  String? sms;
  String? currencySign;
  String? refertext;
  int? totalItems;
  String? androidAppLink;
  String? paymentCurrency;
  String? iosAppLink;
  String? imageUrl;
  int? wishlistCount;
  double? userwallet;
  String? userServerKey;
  String? storeServerKey;
  String? driverServerKey;
  int? liveChat;

  AppInfo();

  AppInfo.fromJson(Map<String, dynamic> json) {
    try {
      status = json["status"];
      message = json["message"];
      lastLoc = json["last_loc"] != null ? int.parse('${json["last_loc"]}') : null;
      phoneNumberLength = json["phone_number_length"] != null ? int.parse('${json["phone_number_length"]}') : null;
      appName = json["app_name"];
      appLogo = json["app_logo"];
      firebase = json["firebase"];
      countryCode = json["country_code"] != null ? int.parse('${json["country_code"]}') : null;
      firebaseIso = json["firebase_iso"];
      sms = json["sms"];
      currencySign = json["currency_sign"];
      refertext = json["refertext"];
      totalItems = json["total_items"] != null ? int.parse('${json["total_items"]}') : null;
      androidAppLink = json["android_app_link"];
      paymentCurrency = json["payment_currency"];
      iosAppLink = json["ios_app_link"];
      imageUrl = json["image_url"] != null ? _addSlashIfNeeded(json["image_url"]) : null;
      wishlistCount = json["wishlist_count"] != null ? int.parse('${json["wishlist_count"]}') : null;
      userwallet = json["userwallet"] != null ? double.parse('${json["userwallet"]}') : null;
      liveChat = json['live_chat'] != null ? int.parse('${json['live_chat']}') : null;
      userServerKey = json['user_server_key'];
      storeServerKey = json['store_server_key'];
      driverServerKey = json['driver_server_key'];
    } catch (e) {
      debugPrint("Exception - app_info_model.dart - AppInfo.fromJson():$e");
    }
  }

  String _addSlashIfNeeded(String url) {
    var uri = Uri.parse(url);
    if (uri.path.isEmpty || uri.pathSegments.length == 1) {
      return '$url/';
    } else {
      return url;
    }
  }
}
