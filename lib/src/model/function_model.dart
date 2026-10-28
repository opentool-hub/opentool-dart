import 'package:json_annotation/json_annotation.dart';
import 'parameter.dart';
import 'return.dart';
import 'schema.dart';

part 'function_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
class FunctionModel {
  String name;
  String description;
  List<Parameter> parameters;
  @JsonKey(name: "return")
  Return? return_;

  /// for once return
  Map<String, Return>? stream;

  /// eventName -> Schema, for streaming return

  FunctionModel({
    required this.name,
    required this.description,
    required this.parameters,
    this.return_,
    this.stream,
  });

  factory FunctionModel.fromJson(
    Map<String, dynamic> json, {
    SchemaResolver? schemaResolver,
    String path = 'function',
  }) {
    final rawParameters = json['parameters'];
    if (rawParameters is! List) {
      throw FormatException('$path.parameters: expected an array.');
    }
    final parameters = <Parameter>[];
    for (var i = 0; i < rawParameters.length; i++) {
      final rawParameter = rawParameters[i];
      if (rawParameter is! Map<String, dynamic>) {
        throw FormatException('$path.parameters[$i]: expected an object.');
      }
      parameters.add(
        Parameter.fromJson(
          rawParameter,
          schemaResolver: schemaResolver,
          path: '$path.parameters[$i]',
        ),
      );
    }

    Return? returnValue;
    final rawReturn = json['return'];
    if (rawReturn != null) {
      if (rawReturn is! Map<String, dynamic>) {
        throw FormatException('$path.return: expected an object.');
      }
      returnValue = Return.fromJson(
        rawReturn,
        schemaResolver: schemaResolver,
        path: '$path.return',
      );
    }

    Map<String, Return>? stream;
    final rawStream = json['stream'];
    if (rawStream != null) {
      if (rawStream is! Map<String, dynamic>) {
        throw FormatException('$path.stream: expected an object.');
      }
      stream = {};
      for (final entry in rawStream.entries) {
        if (entry.value is! Map<String, dynamic>) {
          throw FormatException(
            '$path.stream.${entry.key}: expected an object.',
          );
        }
        stream[entry.key] = Return.fromJson(
          entry.value as Map<String, dynamic>,
          schemaResolver: schemaResolver,
          path: '$path.stream.${entry.key}',
        );
      }
    }

    return FunctionModel(
      name: json['name'] as String,
      description: json['description'] as String,
      parameters: parameters,
      return_: returnValue,
      stream: stream,
    );
  }

  Map<String, dynamic> toJson() => _$FunctionModelToJson(this);
}
