import 'package:flutter/foundation.dart';
import 'package:user/models/banner_model.dart';
import 'package:user/models/category_list_model.dart';
import 'package:user/models/category_product_model.dart';

class HomeScreenData {
  String? status;
  String? message;
  List<CategoryList> topCat = [];
  List<CategoryProdList> catProdList = [];
  List<Banner> banner = [];
  List<Banner> secondBanner = [];
  List<CategoryList> categoryList = [];
  List<Product> dealproduct = [];
  List<Product> topselling = [];
  List<Product> recentSellingProductList = [];
  List<Product> whatsnewProductList = [];
  List<Product> spotLightProductList = [];

  HomeScreenData();

  HomeScreenData.fromJson(Map<String, dynamic> json) {
    try {
      status = json["status"];
      message = json["message"];
      banner = json["banner"] != null
          ? List<Banner>.from(json["banner"].map((x) => Banner.fromJson(x)))
          : [];
      secondBanner = json["second_banner"] != null
          ? List<Banner>.from(
              json["second_banner"].map((x) => Banner.fromJson(x)))
          : [];
      topCat = json["top_cat"] != null
          ? List<CategoryList>.from(
              json["top_cat"].map((x) => CategoryList.fromJson(x)))
          : [];
      dealproduct = json["dealproduct"] != null
          ? List<Product>.from(
              json["dealproduct"].map((x) => Product.fromJson(x)))
          : [];
      topselling = json["topselling"] != null
          ? List<Product>.from(
              json["topselling"].map((x) => Product.fromJson(x)))
          : [];
      categoryList = json['top_cat'] != null
          ? List<CategoryList>.from(
              json["top_cat"].map((x) => CategoryList.fromJson(x)))
          : [];
      recentSellingProductList = json['recentselling'] != null
          ? List<Product>.from(
              json["recentselling"].map((x) => Product.fromJson(x)))
          : [];
      whatsnewProductList = json['whatsnew'] != null
          ? List<Product>.from(json["whatsnew"].map((x) => Product.fromJson(x)))
          : [];
      spotLightProductList = json['spotlight'] != null
          ? List<Product>.from(
              json["spotlight"].map((x) => Product.fromJson(x)))
          : [];
      catProdList = json['category'] != null
          ? List<CategoryProdList>.from(
          json["category"].map((x) => CategoryProdList.fromJson(x)))
          : [];
    } catch (e) {
      debugPrint(
          "Exception - home_screen_data_model.dart - HomeScreenData.fromJson():$e");
    }
  }
}

class CategoryProdList {
  int? catId;
  String? catTitle;
  String? description;
  List<Product> products = [];

  CategoryProdList();

  CategoryProdList.fromJson(Map<String, dynamic> json) {
    try {
      catId = json["cat_id"] != null ? int.parse('${json["cat_id"]}') : null;
      catTitle = json["cat_title"] != null ? '${json["cat_title"]}' : null;
      description =
          json["description"] != null ? '${json["description"]}' : null;
      products = json['products'] != null
          ? List<Product>.from(json["products"].map((x) => Product.fromJson(x)))
          : [];
    } catch (e) {
      debugPrint("Exception - CategoryProdList.dart - CategoryProdList.fromJson():$e");
    }
  }
}
