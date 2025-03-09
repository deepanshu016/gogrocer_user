import 'package:flutter/foundation.dart';

class LocalNotification {
  String? firstName;
  String? lastName;
  String? senderId;
  String? route;
  String? chatId;
  String? otherGlobalId;
  String? userId;
  String? fcmToken;
  String? title;
  String? body;
  String? userToken;

  LocalNotification();

  LocalNotification.fromJson(Map<String, dynamic> json) {
    try {
      firstName = json['firstName'];
      lastName = json['lastName'];
      senderId = json['senderId'];
      route = json['route'];
      chatId = json['chatId'];
      otherGlobalId =
          json['otherGlobalId'];
      userId = json['userId'];
      fcmToken = json['fcmToken'];
      title = json['title'];
      body = json['body'];
      userToken = json['userToken'];
    } catch (e) {
      debugPrint("Exception - localNorificationModel.dart - LocalNotification.fromJson():$e");
    }
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'senderId': senderId,
        'route': route,
        'chatId': chatId,
        'otherGlobalId': otherGlobalId,
        'userId': userId,
        'fcmToken': fcmToken,
        'title': title,
        'body': body,
        'userToken': userToken,
      };
}
