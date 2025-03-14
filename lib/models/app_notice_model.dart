import 'package:flutter/foundation.dart';

class AppNotice {
  int? id;
  int? status;
  String? notice;
  AppNotice();

  AppNotice.fromJson(Map<String, dynamic> json) {
    try {
      id = json['app_notice_id'] != null ? int.parse(json['app_notice_id'].toString()) : null;
      status = json['status'] != null ? int.parse(json['status'].toString()) : null;
      notice = json['notice'];
    } catch (e) {
      debugPrint("Exception - app_notice_model.dart - AppNotice.fromJson():$e");
    }
  }
}
