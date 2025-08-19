import 'package:json_annotation/json_annotation.dart';

part 'server.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Server {
  String url;
  String? description;

  Server({required this.url, this.description});

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);

  Map<String, dynamic> toJson() => _$ServerToJson(this);
}
