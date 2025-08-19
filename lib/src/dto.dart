import 'package:json_annotation/json_annotation.dart';

part 'dto.g.dart';

const String JSONRPC_VERSION = "2.0";
const DEFAULT_PORT = 9627;
const DEFAULT_PREFIX = "/opentool";

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Version {
  late String version;

  Version({required this.version});

  factory Version.fromJson(Map<String, dynamic> json) => _$VersionFromJson(json);

  Map<String, dynamic> toJson() => _$VersionToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class JsonRPCHttpRequestBody {
  String jsonrpc = JSONRPC_VERSION;
  late String method;
  Map<String, dynamic>? params;
  late String id;

  JsonRPCHttpRequestBody({required this.method, required this.params, required this.id});

  factory JsonRPCHttpRequestBody.fromJson(Map<String, dynamic> json) => _$JsonRPCHttpRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$JsonRPCHttpRequestBodyToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class JsonRPCHttpResponseBody {
  String jsonrpc = JSONRPC_VERSION;
  Map<String, dynamic> result;
  JsonRPCHttpResponseBodyError? error;
  String id;
  JsonRPCHttpResponseBody({required this.result, this.error, required this.id});

  factory JsonRPCHttpResponseBody.fromJson(Map<String, dynamic> json) => _$JsonRPCHttpResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$JsonRPCHttpResponseBodyToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class JsonRPCHttpResponseBodyError {
  late int code;
  late String message;

  JsonRPCHttpResponseBodyError({required this.code, required this.message});

  factory JsonRPCHttpResponseBodyError.fromJson(Map<String, dynamic> json) => _$JsonRPCHttpResponseBodyErrorFromJson(json);

  Map<String, dynamic> toJson() => _$JsonRPCHttpResponseBodyErrorToJson(this);
}