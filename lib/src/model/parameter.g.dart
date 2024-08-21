// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Parameter _$ParameterFromJson(Map<String, dynamic> json) => Parameter(
      name: json['name'] as String,
      description: json['description'] as String?,
      schema: Schema.fromJson(json['schema'] as Map<String, dynamic>),
      required: json['required'] as bool? ?? false,
    );

Map<String, dynamic> _$ParameterToJson(Parameter instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'schema': instance.schema,
      'required': instance.required,
    };
