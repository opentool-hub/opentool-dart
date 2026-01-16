import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'exception.g.dart';

abstract class ServerException implements Exception {
  int get code;
  String get message;

  Map<String, dynamic> toJson();
}

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
class JsonParseException implements ServerException {
  final int code = -32700;
  final String message;

  JsonParseException({String? message}) : message = message ?? 'Parse error';

  Map<String, dynamic> toJson() => _$JsonParseExceptionToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
class InvalidJsonPayloadException implements ServerException {
  final int code = -32700;
  final String message;

  const InvalidJsonPayloadException({
    this.message = 'Invalid JSON payload: expected object',
  });

  Map<String, dynamic> toJson() => _$InvalidJsonPayloadExceptionToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
