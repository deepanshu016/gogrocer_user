import 'package:flutter/foundation.dart';

class Mapby {
  int? id;
  int? mapbox;
  int? googleMap;
  Mapby();

  Mapby.fromJson(Map<String, dynamic> json) {
    try {
      id = json['map_id'] != null ? int.parse(json['map_id'].toString()) : null;
      mapbox = json['mapbox'] != null ? int.parse(json['mapbox'].toString()) : null;
      googleMap = json['google_map'] != null ? int.parse(json['google_map'].toString()) : null;
    } catch (e) {
      debugPrint("Exception - map_by_model.dart - Mapby.fromJson():$e");
    }
  }
}
