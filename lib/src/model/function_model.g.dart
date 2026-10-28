// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'function_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$FunctionModelToJson(FunctionModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'parameters': instance.parameters.map((e) => e.toJson()).toList(),
      'return': ?instance.return_?.toJson(),
      'stream': ?instance.stream?.map((k, e) => MapEntry(k, e.toJson())),
    };
