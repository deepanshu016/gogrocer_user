import 'package:flutter/foundation.dart';

class City {
  int? cityId;
  String? cityName;
  City();

  City.fromJson(Map<String, dynamic> json) {
    try {
      cityId = json['city_id'] != null ? int.parse(json['city_id'].toString()) : null;
      cityName = json['city_name'];
    } catch (e) {
      debugPrint("Exception - city_model.dart - City.fromJson():$e");
    }
  }
}
