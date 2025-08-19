import 'package:json_annotation/json_annotation.dart';

part 'dto.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RegisterInfo {
  String file;
  String host;
  int port;
  String prefix;
  List<String>? apiKeys;
  int pid;

  RegisterInfo({required this.file, required this.host, required this.port, required this.prefix, this.apiKeys, required this.pid});

  factory RegisterInfo.fromJson(Map<String, dynamic> json) => _$RegisterInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterInfoToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RegisterResult {
  String id;
  String? error;
  RegisterResult({required this.id, this.error});

  factory RegisterResult.fromJson(Map<String, dynamic> json) => _$RegisterResultFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResultToJson(this);
}