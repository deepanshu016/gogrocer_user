import 'package:flutter/foundation.dart';
import 'package:user/models/category_product_model.dart';

class ProductDetail{
  Product? productDetail;
  List<Product> similarProductList = [];

  ProductDetail();
  ProductDetail.fromJson(Map<String, dynamic> json) {
    try {
     
      productDetail = json['detail'] != null ? Product.fromJson(json['detail']) : null;
      similarProductList = json['similar_product'] != null ? List<Product>.from(json['similar_product'].map((x) => Product.fromJson(x))) : [];
    } catch (e) {
      debugPrint("Exception - product_detail_model.dart - ProductDetail.fromJson():$e");
    }
  }
  
}