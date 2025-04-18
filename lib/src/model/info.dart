import 'package:json_annotation/json_annotation.dart';

part 'info.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Info {
  String title;
  String? description;
  String version;

  Info({required this.title, this.description, required this.version});

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);

  Map<String, dynamic> toJson() => _$InfoToJson(this);
}