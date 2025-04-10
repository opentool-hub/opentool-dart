import 'package:json_annotation/json_annotation.dart';
import 'schema.dart';

part 'parameter.g.dart';

@JsonSerializable(explicitToJson: true)
class Parameter {
  String name;
  @JsonKey(includeIfNull: false) String? description;
  Schema schema;
  bool required;

  Parameter({required this.name, this.description, required this.schema, required this.required});

  factory Parameter.fromJson(Map<String, dynamic> json) => _$ParameterFromJson(json);

  Map<String, dynamic> toJson() => _$ParameterToJson(this);
}