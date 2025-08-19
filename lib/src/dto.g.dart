// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Version _$VersionFromJson(Map<String, dynamic> json) =>
    Version(version: json['version'] as String);

Map<String, dynamic> _$VersionToJson(Version instance) => <String, dynamic>{
  'version': instance.version,
};

JsonRPCHttpRequestBody _$JsonRPCHttpRequestBodyFromJson(
  Map<String, dynamic> json,
) => JsonRPCHttpRequestBody(
  method: json['method'] as String,
  params: json['params'] as Map<String, dynamic>?,
  id: json['id'] as String,
)..jsonrpc = json['jsonrpc'] as String;

Map<String, dynamic> _$JsonRPCHttpRequestBodyToJson(
  JsonRPCHttpRequestBody instance,
) => <String, dynamic>{
  'jsonrpc': instance.jsonrpc,
  'method': instance.method,
  'params': ?instance.params,
  'id': instance.id,
};

JsonRPCHttpResponseBody _$JsonRPCHttpResponseBodyFromJson(
  Map<String, dynamic> json,
) => JsonRPCHttpResponseBody(
  result: json['result'] as Map<String, dynamic>,
  error: json['error'] == null
      ? null
      : JsonRPCHttpResponseBodyError.fromJson(
          json['error'] as Map<String, dynamic>,
        ),
  id: json['id'] as String,
)..jsonrpc = json['jsonrpc'] as String;

Map<String, dynamic> _$JsonRPCHttpResponseBodyToJson(
  JsonRPCHttpResponseBody instance,
) => <String, dynamic>{
  'jsonrpc': instance.jsonrpc,
  'result': instance.result,
  'error': ?instance.error?.toJson(),
  'id': instance.id,
};

JsonRPCHttpResponseBodyError _$JsonRPCHttpResponseBodyErrorFromJson(
  Map<String, dynamic> json,
) => JsonRPCHttpResponseBodyError(
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
);

Map<String, dynamic> _$JsonRPCHttpResponseBodyErrorToJson(
  JsonRPCHttpResponseBodyError instance,
) => <String, dynamic>{'code': instance.code, 'message': instance.message};
