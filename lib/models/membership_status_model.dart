import 'package:flutter/foundation.dart';
import 'package:user/models/membership_model.dart';

class MembershipStatus {
  MembershipModel? membershipStatus;
  String? status;
  MembershipStatus();
  MembershipStatus.fromJson(Map<String, dynamic> json) {
    try {
      membershipStatus = json['membership_status'] != null ? MembershipModel.fromJson(json['membership_status']) : null;
      status = json["status"];
    } catch (e) {
      debugPrint("Exception - membership_status_model.dart - MembershipStatus.fromJson():$e");
    }
  }
}
