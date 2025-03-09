import 'package:flutter/foundation.dart';

class GoogleMapModel {
  int? id;
  String? mapApiKey;

  GoogleMapModel();

  GoogleMapModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'] != null ? int.parse(json['id'].toString()) : null;
      mapApiKey = json['map_api_key'];
    } catch (e) {
      debugPrint("Exception - google_map_model.dart - GoogleMapModel.fromJson():$e");
    }
  }
}
