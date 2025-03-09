import 'package:flutter/foundation.dart';

class Banner {
  int? bannerId;
  String? bannerName;
  String? bannerImage;
  int? storeId;
  int? catId;
  String? type;
  String? title;
  int? varientId;
  String? productName;
  String? qtyUnit;

  Banner();
  Banner.fromJson(Map<String, dynamic> json) {
    try {
      bannerId = json["banner_id"] != null ? int.parse(json["banner_id"].toString()) : null;
      bannerName = json["banner_name"];
      bannerImage = json["banner_image"];
      storeId = json["store_id"] != null ? int.parse(json["store_id"].toString()) : null;
      catId = json["cat_id"] != null ? int.parse(json["cat_id"].toString()) : null;
      type = json["type"];
      title = json["title"];
      varientId = json["varient_id"] != null ? int.parse(json["varient_id"].toString()) : null;
      productName = json["product_name"];
      qtyUnit = json["qty_unit"];
    } catch (e) {
      debugPrint("Exception - banner_model.dart - Banner.fromJson():$e");
    }
  }
}
