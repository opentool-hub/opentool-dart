import 'package:json_annotation/json_annotation.dart';

part 'schema.g.dart';

class SchemaType {
  static const String BOOLEAN = "boolean";
  static const String INTEGER = "integer";
  static const String NUMBER = "number";
  static const String STRING = "string";
  static const String ARRAY = "array";
  static const String OBJECT = "object";
}

@JsonSerializable(explicitToJson: true)
class Schema {
  String type;  // data_type: boolean, integer, number, string, array, object
  @JsonKey(includeIfNull: false) String? description;
  @JsonKey(includeIfNull: false) Map<String, Schema>? properties;  // for object
  @JsonKey(includeIfNull: false) Schema? items;  // for array
  @JsonKey(name: "enum", includeIfNull: false) List<String>? enum_;// for enum
  @JsonKey(includeIfNull: false) List<String>? required;

  Schema({required this.type, this.description, this.properties, this.items, this.enum_, this.required});

  factory Schema.fromJson(Map<String, dynamic> json) {
    if (json["\$ref"] != null) {
      return _fromRef(json["\$ref"] as String);
    }
    return _$SchemaFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SchemaToJson(this);

  static Schema _fromRef(String ref) {
    List<String> parts = ref.split("/");
    if (parts[0] == "#" && parts[1] == "schemas") {
      String refName = parts[2];
      Schema? schema = SchemasSingleton.getInstance()[refName];
      if (schema != null) {
        return schema;
      } else {
        throw FormatException("#ref not found: $ref");
      }
    } else {
      throw FormatException("#ref format exception: $ref");
    }
  }
}

class SchemasSingleton {
  static Map<String, Schema> _schemas = {};

  static initInstance(Map<String, dynamic> schemasJson) {
    schemasJson.forEach((key, value) {
      String schemaName = key;
      Map<String, dynamic> schemaMap = value as Map<String, dynamic>;
      if (schemaMap["\$ref"] == null) {
        _schemas[schemaName] = Schema.fromJson(schemaMap);
      }
    });
  }

  static Map<String, Schema> getInstance() => _schemas;
}