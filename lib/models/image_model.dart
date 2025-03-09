import 'package:flutter/cupertino.dart';

class ImageModel {
  String? image;
  ImageModel();
  ImageModel.fromJson(Map<String, dynamic> json) {
    try {
      image = json['image'] ?? '';
    } catch (e) {
      debugPrint("Exception - ImageModel.dart - ImageModel.fromJson():$e");
    }
  }
}
