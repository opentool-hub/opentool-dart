// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterInfo _$RegisterInfoFromJson(Map<String, dynamic> json) => RegisterInfo(
  file: json['file'] as String,
  host: json['host'] as String,
  port: (json['port'] as num).toInt(),
  prefix: json['prefix'] as String,
  apiKeys: (json['apiKeys'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  pid: (json['pid'] as num).toInt(),
);

Map<String, dynamic> _$RegisterInfoToJson(RegisterInfo instance) =>
    <String, dynamic>{
      'file': instance.file,
      'host': instance.host,
      'port': instance.port,
      'prefix': instance.prefix,
      'apiKeys': ?instance.apiKeys,
      'pid': instance.pid,
    };

RegisterResult _$RegisterResultFromJson(Map<String, dynamic> json) =>
    RegisterResult(id: json['id'] as String, error: json['error'] as String?);

Map<String, dynamic> _$RegisterResultToJson(RegisterResult instance) =>
    <String, dynamic>{'id': instance.id, 'error': ?instance.error};
