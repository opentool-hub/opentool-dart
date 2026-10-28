// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opentool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$OpenToolToJson(OpenTool instance) => <String, dynamic>{
  'opentool': instance.opentool,
  'info': instance.info.toJson(),
  'server': ?instance.server?.toJson(),
  'functions': instance.functions.map((e) => e.toJson()).toList(),
  'schemas': ?instance.schemas?.map((k, e) => MapEntry(k, e.toJson())),
};
