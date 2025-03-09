import 'package:flutter/foundation.dart';

class DioResult<T> {
  int? statusCode;
  String? status;
  String? message;
  T? data;

  DioResult({this.statusCode, this.data, this.status});
  DioResult.fromJson(dynamic response, T recordList) {
    try {
      status = response.data['status'].toString();
      message = response.data['message'];
      statusCode = response.statusCode;
      data = recordList;
    } catch (e) {
      debugPrint("Exception - dio_result.dart - DioResult.fromJson():$e");
    }
  }
}
