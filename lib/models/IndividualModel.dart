import 'package:flutter/cupertino.dart';

class IndividualModel {
  String name;
  String url;
  String startTime;
  String duration;
  String endTime;

  IndividualModel({
    @required this.name,
    @required this.duration,
    @required this.url,
    @required this.endTime,
    @required this.startTime,
  });

  factory IndividualModel.fromJson(Map<String, dynamic> json) {
    return IndividualModel(
      name: json["name"],
      duration: json["duration"],
      startTime: json["start_time"],
      url: json["url"],
      endTime: json["end_time"],
    );
  }
}
