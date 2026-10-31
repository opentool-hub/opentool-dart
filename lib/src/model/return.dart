import 'package:json_annotation/json_annotation.dart';

import 'schema.dart';

part 'return.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
class Return {
  String name;
  String? description;
  Schema schema;

  Return({required this.name, this.description, required this.schema});

  factory Return.fromJson(
    Map<String, dynamic> json, {
    SchemaResolver? schemaResolver,
    String path = 'return',
  }) {
    final rawSchema = json['schema'];
    if (rawSchema is! Map<String, dynamic> && rawSchema is! bool) {
      throw FormatException(
        '$path.schema: expected a schema object or boolean schema.',
      );
    }
    return Return(
      name: json['name'] as String,
      description: json['description'] as String?,
      schema:
          schemaResolver?.parseSchema(
            rawSchema as Object,
            path: '$path.schema',
          ) ??
          Schema.fromJson(rawSchema as Object),
    );
  }

  Map<String, dynamic> toJson() => _$ReturnToJson(this);
}
