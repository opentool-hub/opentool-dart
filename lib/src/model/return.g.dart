// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Return _$ReturnFromJson(Map<String, dynamic> json) => Return(
      name: json['name'] as String,
      description: json['description'] as String?,
      schema: Schema.fromJson(json['schema'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReturnToJson(Return instance) => <String, dynamic>{
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      'schema': instance.schema.toJson(),
    };
