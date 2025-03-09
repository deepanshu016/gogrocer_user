import 'package:flutter/foundation.dart';

class TimeSlot{
  String? timeslot;
  String? availibility;

  TimeSlot();

  TimeSlot.fromJson(Map<String, dynamic> json) {
    try {
      timeslot = json['timeslot'] ?? '';
      availibility = json['availibility'] ?? '';
    } catch (e) {
      debugPrint("Exception - time_slot_model.dart - TimeSlot.fromJson():$e");
    }
  }
}