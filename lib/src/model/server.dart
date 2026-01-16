import 'package:json_annotation/json_annotation.dart';

part 'server.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ServerConfig {
  String url;
  String? description;

  ServerConfig({required this.url, this.description});

  factory ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ServerConfigToJson(this);
}
