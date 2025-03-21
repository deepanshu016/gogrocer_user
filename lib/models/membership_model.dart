import 'package:flutter/foundation.dart';

class MembershipModel {
  int? planId;
  String? image;
  String? planName;
  int? freeDelivery;
  int? reward;
  int? instantDelivery;
  String? planDescription;
  int? days;
  double? price;
  int? hide;

  MembershipModel();
  MembershipModel.fromJson(Map<String, dynamic> json) {
    try {
      planId = json["plan_id"] != null ? int.parse('${json["plan_id"]}') : null;
      image = (json["image"] != null && '${json["image"]}'!='N/A') ? json["image"] : null;
      planName = json["plan_name"];
      freeDelivery = json["free_delivery"] != null ? int.parse('${json["free_delivery"]}') : null;
      reward = json["reward"] != null ? int.parse('${json["reward"]}') : null;
      instantDelivery = json["instant_delivery"] != null ? int.parse('${json["instant_delivery"]}') : null;
      planDescription = json["plan_description"];
      days = json["days"] != null ? int.parse('${json["days"]}') : null;
      price = json["price"] != null ? double.parse('${json["price"]}') : null;
      hide = json["hide"] != null ? int.parse('${json["hide"]}') : null;
    } catch (e) {
      debugPrint("Exception - membership_model.dart - Membership.fromJson():$e");
    }
  }
}
