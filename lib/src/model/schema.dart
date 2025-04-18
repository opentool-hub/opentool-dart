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

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Schema {
  String type;  // data_type: boolean, integer, number, string, array, object
  String? description;
  Map<String, Schema>? properties;  // for object
  Schema? items;  // for array
  @JsonKey(name: "enum") List<Object?>? enum_;// for enum
  List<String>? required;

  Schema({required this.type, this.description, this.properties, this.items, this.enum_, this.required});

  factory Schema.fromJson(Map<String, dynamic> json) {
    if (json["\$ref"] != null) {
      Schema schema =  _fromRef(json["\$ref"] as String);
      schema._validateEnumConsistency();
      return schema;
    }
    Schema schema =  _$SchemaFromJson(json);
    schema._validateEnumConsistency();
    return schema;
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

  void _validateEnumConsistency() {
    if (enum_ == null || enum_!.isEmpty) {
      return;
    }
    for (var i = 0; i < enum_!.length; i++) {
      var value = enum_![i];
      if (!_isValueConsistentWithType(value)) {
        throw FormatException('Enum value at index $i ("$value") does not match schema type "$type".');
      }
    }
  }

  bool _isValueConsistentWithType(Object? value) {
    switch (type) {
      case 'string':
        return value is String || value == null;
      case 'integer':
        return value is int || value == null;
      case 'number':
        return (value is num && value is! bool) || value == null;
      case 'boolean':
        return value is bool || value == null;
      case 'null':
        return value == null;
      default:
        return true;
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