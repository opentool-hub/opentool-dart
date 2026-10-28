import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'exception.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
class FunctionNotSupportedException implements Exception {
  final int code = 405;
  late String message;

  FunctionNotSupportedException({required String functionName}) {
    this.message = "Function Not Supported: $functionName";
  }

  Map<String, dynamic> toJson() => _$FunctionNotSupportedExceptionToJson(this);

  @override
  String toString() => jsonEncode(this.toJson());
}

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
class InvalidArgumentsException implements Exception {
  final int code = 400;
  late String message;

  InvalidArgumentsException({required Map<String, dynamic>? arguments}) {
    this.message = "Invalid Arguments: ${jsonEncode(arguments)}";
  }

  Map<String, dynamic> toJson() => _$InvalidArgumentsExceptionToJson(this);

  @override
  String toString() => jsonEncode(this.toJson());
}

/// When client catch `ToolBreakException`. The client should be stopped calling.
@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
class ToolBreakException implements Exception {
  final int code = 500;
  late String? message;

  ToolBreakException(this.message);

  Map<String, dynamic> toJson() => _$ToolBreakExceptionToJson(this);

  @override
  String toString() => jsonEncode(this.toJson());
}

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
class JsonParserException implements Exception {
  final int code = 404;
  late String message = "Json Parser NOT implement";

  JsonParserException();

  Map<String, dynamic> toJson() => _$JsonParserExceptionToJson(this);

  @override
  String toString() => jsonEncode(this.toJson());
}

/// Returned by `/load` when the server has no OpenTool document for this tool.
class ToolNotFoundException implements Exception {
  static const String code = 'TOOL_NOT_FOUND';
  static const String defaultMessage = 'Tool metadata not found';

  final String message;

  const ToolNotFoundException({this.message = defaultMessage});

  Map<String, dynamic> toJson() => {'code': code, 'message': message};

  @override
  String toString() => jsonEncode(toJson());
}
