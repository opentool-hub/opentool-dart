import 'package:json_annotation/json_annotation.dart';
import 'schema.dart';

part 'return.g.dart';

@JsonSerializable(explicitToJson: true)
class Return {
  String name;
  @JsonKey(includeIfNull: false) String? description;
  Schema schema;

  Return({required this.name, this.description, required this.schema});

  factory Return.fromJson(Map<String, dynamic> json) => _$ReturnFromJson(json);

  Map<String, dynamic> toJson() => _$ReturnToJson(this);
}