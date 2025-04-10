// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'function_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FunctionModel _$FunctionModelFromJson(Map<String, dynamic> json) =>
    FunctionModel(
      name: json['name'] as String,
      description: json['description'] as String,
      parameters: (json['parameters'] as List<dynamic>)
          .map((e) => Parameter.fromJson(e as Map<String, dynamic>))
          .toList(),
      return_: json['return'] == null
          ? null
          : Return.fromJson(json['return'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FunctionModelToJson(FunctionModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'parameters': instance.parameters.map((e) => e.toJson()).toList(),
      'return': instance.return_?.toJson(),
    };
