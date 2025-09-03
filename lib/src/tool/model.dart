import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

class EventType {
  static const String START = "start";
  static const String DATA = "data";
  static const String ERROR = "error";
  static const String DONE = "done";
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Event {
  String name;
  Map<String, dynamic> data;

  Event({required this.name, required this.data});

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}