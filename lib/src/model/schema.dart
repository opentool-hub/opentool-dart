class SchemaType {
  static const String BOOLEAN = 'boolean';
  static const String INTEGER = 'integer';
  static const String NUMBER = 'number';
  static const String STRING = 'string';
  static const String ARRAY = 'array';
  static const String OBJECT = 'object';
  static const String NULL = 'null';

  static const Set<String> values = {
    BOOLEAN,
    INTEGER,
    NUMBER,
    STRING,
    ARRAY,
    OBJECT,
    NULL,
  };
}

/// A supported subset of JSON Schema used by OpenTool function signatures.
///
/// [type] accepts either one JSON Schema type name or a list of type names.
/// Composition is supported through [oneOf], [anyOf], and [allOf].
class Schema {
  /// A single type name or a union of type names, such as `['string', 'null']`.
  Object? type;
  String? description;
  Map<String, Schema>? properties;
  Schema? items;

  /// `additionalProperties` can be a boolean or a schema.
  Object? additionalProperties;

  List<Object?>? enum_;
  List<String>? required;
  List<Schema>? oneOf;
  List<Schema>? anyOf;
  List<Schema>? allOf;

  Schema({
    this.type,
    this.description,
    this.properties,
    this.items,
    this.additionalProperties,
    this.enum_,
    this.required,
    this.oneOf,
    this.anyOf,
    this.allOf,
  });

  factory Schema.fromJson(Map<String, dynamic> json) =>
      SchemaResolver().parseSchema(json);

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    if (type != null) result['type'] = type;
    if (description != null) result['description'] = description;
    if (properties != null) {
      result['properties'] = properties!.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
    }
    if (items != null) result['items'] = items!.toJson();
    if (additionalProperties != null) {
      result['additionalProperties'] = additionalProperties is Schema
          ? (additionalProperties as Schema).toJson()
          : additionalProperties;
    }
    if (enum_ != null) result['enum'] = enum_;
    if (required != null) result['required'] = required;
    if (oneOf != null) {
      result['oneOf'] = oneOf!.map((schema) => schema.toJson()).toList();
    }
    if (anyOf != null) {
      result['anyOf'] = anyOf!.map((schema) => schema.toJson()).toList();
    }
    if (allOf != null) {
      result['allOf'] = allOf!.map((schema) => schema.toJson()).toList();
    }
    return result;
  }
}

/// Resolves local OpenTool schema references without shared global state.
///
/// Supported keywords are `type`, `description`, `properties`, `items`,
/// `additionalProperties`, `enum`, `required`, `$ref`, `oneOf`, `anyOf`, and
/// `allOf`. References must point to `#/schemas/<name>`. Recursive references
/// are rejected with a path-aware [FormatException].
class SchemaResolver {
  static const Set<String> _supportedKeywords = {
    r'$ref',
    'type',
    'description',
    'properties',
    'items',
    'additionalProperties',
    'enum',
    'required',
    'oneOf',
    'anyOf',
    'allOf',
  };

  final Map<String, dynamic> _definitions;
  final Map<String, Schema> _resolved = {};
  final Set<String> _resolving = {};

  SchemaResolver([Map<String, dynamic>? definitions])
    : _definitions = definitions ?? const {};

  Map<String, Schema> resolveAll() {
    final result = <String, Schema>{};
    for (final name in _definitions.keys) {
      result[name] = _resolveDefinition(name, 'schemas.$name');
    }
    return result;
  }

  Schema parseSchema(Map<String, dynamic> json, {String path = 'schema'}) =>
      _parseSchema(json, path);

  Schema _resolveDefinition(String name, String path) {
    final cached = _resolved[name];
    if (cached != null) return cached;
    if (!_definitions.containsKey(name)) {
      throw FormatException('$path: schema "$name" was not found.');
    }
    if (!_resolving.add(name)) {
      throw FormatException(
        '$path: recursive schema reference "#/schemas/$name" is not supported.',
      );
    }

    try {
      final raw = _definitions[name];
      if (raw is! Map<String, dynamic>) {
        throw FormatException('$path: expected a schema object.');
      }
      final schema = _parseSchema(raw, path);
      _resolved[name] = schema;
      return schema;
    } finally {
      _resolving.remove(name);
    }
  }

  Schema _parseSchema(Map<String, dynamic> json, String path) {
    for (final keyword in json.keys) {
      if (!_supportedKeywords.contains(keyword)) {
        throw FormatException('$path: unsupported schema keyword "$keyword".');
      }
    }

    if (json.containsKey(r'$ref')) {
      final rawRef = json[r'$ref'];
      if (rawRef is! String) {
        throw FormatException('$path.\$ref: expected a string reference.');
      }
      final name = _schemaNameFromRef(rawRef, '$path.\$ref');
      final target = _resolveDefinition(name, '$path.\$ref');
      final siblingJson = <String, dynamic>{
        for (final entry in json.entries)
          if (entry.key != r'$ref' && entry.key != 'description')
            entry.key: entry.value,
      };
      final description = json['description'];
      if (description != null && description is! String) {
        throw FormatException('$path.description: expected a string.');
      }
      if (siblingJson.isEmpty) {
        if (description == null) return target;
        return _copyWithDescription(target, description as String);
      }
      return Schema(
        description: description as String? ?? target.description,
        allOf: [target, _parseSchema(siblingJson, path)],
      );
    }

    final rawType = json['type'];
    final type = rawType == null ? null : _parseType(rawType, '$path.type');

    final description = json['description'];
    if (description != null && description is! String) {
      throw FormatException('$path.description: expected a string.');
    }

    final properties = <String, Schema>{};
    if (json.containsKey('properties')) {
      final rawProperties = json['properties'];
      if (rawProperties is! Map<String, dynamic>) {
        throw FormatException('$path.properties: expected an object.');
      }
      for (final entry in rawProperties.entries) {
        final child = entry.value;
        if (child is! Map<String, dynamic>) {
          throw FormatException(
            '$path.properties.${entry.key}: expected a schema object.',
          );
        }
        properties[entry.key] = _parseSchema(
          child,
          '$path.properties.${entry.key}',
        );
      }
    }

    Schema? items;
    if (json.containsKey('items')) {
      final rawItems = json['items'];
      if (rawItems is! Map<String, dynamic>) {
        throw FormatException('$path.items: expected a schema object.');
      }
      items = _parseSchema(rawItems, '$path.items');
    }

    Object? additionalProperties;
    if (json.containsKey('additionalProperties')) {
      final rawAdditionalProperties = json['additionalProperties'];
      if (rawAdditionalProperties is bool) {
        additionalProperties = rawAdditionalProperties;
      } else if (rawAdditionalProperties is Map<String, dynamic>) {
        additionalProperties = _parseSchema(
          rawAdditionalProperties,
          '$path.additionalProperties',
        );
      } else {
        throw FormatException(
          '$path.additionalProperties: expected a boolean or schema object.',
        );
      }
    }

    List<Object?>? enumValues;
    if (json.containsKey('enum')) {
      final rawEnum = json['enum'];
      if (rawEnum is! List) {
        throw FormatException('$path.enum: expected an array.');
      }
      enumValues = List<Object?>.from(rawEnum);
    }

    List<String>? required;
    if (json.containsKey('required')) {
      final rawRequired = json['required'];
      if (rawRequired is! List ||
          rawRequired.any((value) => value is! String)) {
        throw FormatException('$path.required: expected an array of strings.');
      }
      required = List<String>.from(rawRequired);
    }

    final schema = Schema(
      type: type,
      description: description as String?,
      properties: json.containsKey('properties') ? properties : null,
      items: items,
      additionalProperties: additionalProperties,
      enum_: enumValues,
      required: required,
      oneOf: _parseComposition(json, 'oneOf', path),
      anyOf: _parseComposition(json, 'anyOf', path),
      allOf: _parseComposition(json, 'allOf', path),
    );
    _validateEnum(schema, path);
    return schema;
  }

  List<Schema>? _parseComposition(
    Map<String, dynamic> json,
    String keyword,
    String path,
  ) {
    if (!json.containsKey(keyword)) return null;
    final value = json[keyword];
    if (value is! List || value.isEmpty) {
      throw FormatException(
        '$path.$keyword: expected a non-empty array of schemas.',
      );
    }
    final result = <Schema>[];
    for (var i = 0; i < value.length; i++) {
      final child = value[i];
      if (child is! Map<String, dynamic>) {
        throw FormatException('$path.$keyword[$i]: expected a schema object.');
      }
      result.add(_parseSchema(child, '$path.$keyword[$i]'));
    }
    return result;
  }

  Object _parseType(Object rawType, String path) {
    if (rawType is String) {
      if (!SchemaType.values.contains(rawType)) {
        throw FormatException(
          '$path: unsupported JSON Schema type "$rawType".',
        );
      }
      return rawType;
    }
    if (rawType is List) {
      if (rawType.isEmpty || rawType.any((value) => value is! String)) {
        throw FormatException(
          '$path: expected a type name or non-empty array of type names.',
        );
      }
      final types = List<String>.from(rawType);
      for (final value in types) {
        if (!SchemaType.values.contains(value)) {
          throw FormatException(
            '$path: unsupported JSON Schema type "$value".',
          );
        }
      }
      if (types.toSet().length != types.length) {
        throw FormatException('$path: duplicate types are not supported.');
      }
      return types;
    }
    throw FormatException(
      '$path: expected a type name or array of type names.',
    );
  }

  String _schemaNameFromRef(String ref, String path) {
    const prefix = '#/schemas/';
    if (!ref.startsWith(prefix)) {
      throw FormatException(
        '$path: unsupported reference "$ref"; expected #/schemas/<name>.',
      );
    }
    final segment = ref.substring(prefix.length);
    if (segment.isEmpty ||
        segment.contains('/') ||
        RegExp(r'~(?![01])').hasMatch(segment)) {
      throw FormatException('$path: invalid schema reference "$ref".');
    }
    return segment.replaceAll('~1', '/').replaceAll('~0', '~');
  }

  Schema _copyWithDescription(Schema schema, String description) => Schema(
    type: schema.type,
    description: description,
    properties: schema.properties,
    items: schema.items,
    additionalProperties: schema.additionalProperties,
    enum_: schema.enum_,
    required: schema.required,
    oneOf: schema.oneOf,
    anyOf: schema.anyOf,
    allOf: schema.allOf,
  );

  void _validateEnum(Schema schema, String path) {
    if (schema.enum_ == null || schema.type == null) return;
    final types = schema.type is String
        ? [schema.type as String]
        : schema.type as List<String>;
    for (var i = 0; i < schema.enum_!.length; i++) {
      final value = schema.enum_![i];
      if (!types.any((type) => _valueMatchesType(value, type))) {
        throw FormatException(
          '$path.enum[$i]: value "$value" does not match schema type ${types.join(' or ')}.',
        );
      }
    }
  }

  bool _valueMatchesType(Object? value, String type) {
    switch (type) {
      case SchemaType.STRING:
        return value is String;
      case SchemaType.INTEGER:
        return value is int;
      case SchemaType.NUMBER:
        return value is num;
      case SchemaType.BOOLEAN:
        return value is bool;
      case SchemaType.NULL:
        return value == null;
      case SchemaType.ARRAY:
        return value is List;
      case SchemaType.OBJECT:
        return value is Map;
      default:
        return false;
    }
  }
}
