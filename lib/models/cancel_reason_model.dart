import 'package:flutter/foundation.dart';

class CancelReason {
  int? resId;
  String? reason;

  CancelReason.fromJson(Map<String, dynamic> json) {
    try {
      resId = json['res_id'] != null ? int.parse(json['res_id'].toString()) : null;
      reason = json['reason'];
    } catch (e) {
      debugPrint("Exception - cancel_reason_model.dart - CancelReason.fromJson():$e");
    }
  }
}
