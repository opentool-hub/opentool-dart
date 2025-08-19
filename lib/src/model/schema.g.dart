// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schema _$SchemaFromJson(Map<String, dynamic> json) => Schema(
  type: json['type'] as String,
  description: json['description'] as String?,
  properties: (json['properties'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, Schema.fromJson(e as Map<String, dynamic>)),
  ),
  items: json['items'] == null
      ? null
      : Schema.fromJson(json['items'] as Map<String, dynamic>),
  enum_: json['enum'] as List<dynamic>?,
  required: (json['required'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SchemaToJson(Schema instance) => <String, dynamic>{
  'type': instance.type,
  'description': ?instance.description,
  'properties': ?instance.properties?.map((k, e) => MapEntry(k, e.toJson())),
  'items': ?instance.items?.toJson(),
  'enum': ?instance.enum_,
  'required': ?instance.required,
};
