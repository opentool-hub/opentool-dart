import 'package:json_annotation/json_annotation.dart';
import 'schema.dart';

part 'parameter.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
class Parameter {
  String name;
  String? description;
  Schema schema;
  @JsonKey(defaultValue: false)
  bool required;

  Parameter({
    required this.name,
    this.description,
    required this.schema,
    this.required = false,
  });

  factory Parameter.fromJson(
    Map<String, dynamic> json, {
    SchemaResolver? schemaResolver,
    String path = 'parameter',
  }) {
    final rawSchema = json['schema'];
    if (rawSchema is! Map<String, dynamic>) {
      throw FormatException('$path.schema: expected a schema object.');
    }
    return Parameter(
      name: json['name'] as String,
      description: json['description'] as String?,
      schema:
          schemaResolver?.parseSchema(rawSchema, path: '$path.schema') ??
          Schema.fromJson(rawSchema),
      required: json['required'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$ParameterToJson(this);
}
