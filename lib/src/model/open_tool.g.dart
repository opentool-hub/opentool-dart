// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_tool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenTool _$OpenToolFromJson(Map<String, dynamic> json) => OpenTool(
      opentool: json['opentool'] as String,
      info: Info.fromJson(json['info'] as Map<String, dynamic>),
      functions: (json['functions'] as List<dynamic>)
          .map((e) => FunctionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..schemas = (json['schemas'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Schema.fromJson(e as Map<String, dynamic>)),
      );

Map<String, dynamic> _$OpenToolToJson(OpenTool instance) => <String, dynamic>{
      'opentool': instance.opentool,
      'info': instance.info,
      'functions': instance.functions,
      'schemas': instance.schemas,
    };
