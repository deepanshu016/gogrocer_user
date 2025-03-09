import 'package:flutter/foundation.dart';

class Rate {
  String? userName;
  int? rateId;
  int? storeId;
  int? variantId;
  double? rating;
  String? description;
  int? userId;

  Rate();
  Rate.fromJson(Map<String, dynamic> json) {
    try {
      userName = json["user_name"];
      rateId = json["rate_id"] != null ? int.parse(json["rate_id"].toString()) : null;
      storeId = json["store_id"] != null ? int.parse(json["store_id"].toString()) : null;
      variantId = json["varient_id"] != null ? int.parse(json["varient_id"].toString()) : null;
      rating = json["rating"] != null ? double.parse(json["rating"].toString()) : null;
      description = json["description"];
      userId = json["user_id"] != null ? int.parse(json["user_id"].toString()) : null;
    } catch (e) {
      debugPrint("Exception - rate_model.dart - Rate.fromJson():$e");
    }
  }
}
