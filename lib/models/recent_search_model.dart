import 'package:flutter/foundation.dart';

class RecentSearch {
  int? id;
  String? keyword;
  int? userId;

  RecentSearch();
  RecentSearch.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'] != null ? int.parse(json['id'].toString()) : null;
      keyword = json['keyword'];
      userId = json['user_id'] != null ? int.parse(json['user_id'].toString()) : null;
    } catch (e) {
      debugPrint("Exception - recent_search_model.dart - RecentSearch.fromJson():$e");
    }
  }
}
