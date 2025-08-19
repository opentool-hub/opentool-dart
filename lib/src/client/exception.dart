import 'package:json_annotation/json_annotation.dart';

part 'exception.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false, createFactory: false)
class ResponseNullException implements Exception {
  final int code;
  final String message = 'Response is null';

  ResponseNullException(this.code);

  Map<String, dynamic> toJson() => _$ResponseNullExceptionToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false, createFactory: false)
class ErrorNullException implements Exception {
  final int code;
  final String message = 'Error is null';

  ErrorNullException(this.code);

  Map<String, dynamic> toJson() => _$ErrorNullExceptionToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false, createFactory: false)
class OpenToolServerUnauthorizedException implements Exception {
  final int code = 401;
  final String message = "Please check API Key is VALID or NOT";

  Map<String, dynamic> toJson() => _$OpenToolServerUnauthorizedExceptionToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false, createFactory: false)
class OpenToolServerNoAccessException implements Exception {
  final int code = 404;
  final String message = "Please check OpenTool Server is RUNNING or NOT";

  OpenToolServerNoAccessException();

  Map<String, dynamic> toJson() => _$OpenToolServerNoAccessExceptionToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false, createFactory: false)
class OpenToolServerCallException implements Exception {
  final String message;
  OpenToolServerCallException(this.message);

  Map<String, dynamic> toJson() => _$OpenToolServerCallExceptionToJson(this);
}