import 'package:flutter/cupertino.dart';

class AllModel{
  String name;
  String site;
  String url;
  String startTime;
  String duration;
String endTime;


  AllModel(
      {@required this.name,
      @required this.site,
      @required this.duration,
      @required this.url,
      @required this.startTime,
      @required this.endTime,

    });

  factory AllModel.fromJson(Map<String, dynamic> json) {

    return AllModel(
      name: json["name"],
      site: json["site"],
      duration : json["duration"],
      startTime: json["start_time"],
      url: json["url"],
      endTime: json["end_time"],
    );

  }
}
