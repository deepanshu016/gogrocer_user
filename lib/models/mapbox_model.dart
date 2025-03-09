import 'package:flutter/foundation.dart';

class MapBoxModel {
  int? id;
  String? mapApiKey;

  MapBoxModel();

  MapBoxModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['map_id'] != null ? int.parse(json['map_id'].toString()) : null;
      mapApiKey = json['mapbox_api'];
    } catch (e) {
      debugPrint("Exception - mapBoxModelModel.dart - MapBoxModel.fromJson():$e");
    }
  }
}
