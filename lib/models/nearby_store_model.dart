import 'package:flutter/foundation.dart';

class NearStoreModel {
  String? phoneNumber;
  int? delRange;
  int? id;
  String? storeName;
  int? storeStatus;
  String? inactiveReason;
  String? lat;
  String? lng;
  String? storeOpeningTime;
  String? storeClosingTime;
  String? city;
  int? cityId;
  String? deviceId;
  double? distance;
  NearStoreModel();
  NearStoreModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'] != null ? int.parse('${json['id']}') : null;
      phoneNumber = json["phone_number"];
      delRange = json["del_range"] != null ? int.parse(json["del_range"].toString()) : null;
      id = json["id"] != null ? int.parse(json["id"].toString()) : null;
      storeName = json["store_name"];
      storeStatus = json["store_status"] != null ? int.parse(json["store_status"].toString()) : null;
      inactiveReason = json["inactive_reason"];
      lat = json["lat"];
      lng = json["lng"];
      storeOpeningTime = json["store_opening_time"];
      storeClosingTime = json["store_closing_time"];
      city = json["city"];
      cityId = json["city_id"] != null ? int.parse(json["city_id"].toString()) : null;
      distance = json["distance"]?.toDouble();
      deviceId = json["device_id"];
    } catch (e) {
      debugPrint("Exception - nearby_store_model.dart - NearStoreModel.fromJson():$e");
    }
  }
}
