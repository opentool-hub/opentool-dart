import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'exception.g.dart';

@JsonSerializable(createFactory: false)
class FunctionNotSupportedException implements Exception {
  final int code = 405;
  late String message;

  FunctionNotSupportedException({
    required String functionName,
  }) {
    this.message = "Function Not Supported: $functionName";
  }

  Map<String, dynamic> toJson() => _$FunctionNotSupportedExceptionToJson(this);

  @override
  String toString() => jsonEncode(this.toJson());
}