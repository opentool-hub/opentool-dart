import 'package:schema_engine/schema_engine.dart' as json_schema;

typedef SchemaReferenceResolver = Object? Function(String uri);

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

class _SchemaUnset {
  const _SchemaUnset();
}

const _schemaUnset = _SchemaUnset();

/// A JSON Schema node parsed with the declared dialect (2020-12 by default).
///
/// The original JSON value is retained so unsupported annotations and future
/// vocabulary keywords survive a load/serialize cycle. Both object and boolean
/// schemas are supported. Use [validate] to validate an instance.
class Schema {
  final Object _json;
  final Object _engineSchema;
  final Map<Uri, Object?> _resources;
  final Map<bool?, json_schema.CompiledSchema> _validators;
  final SchemaResolver? _resolver;

  Schema._(
    this._json,
    this._engineSchema,
    this._resources,
    this._validators,
    this._resolver,
  );

  /// Creates a schema from any JSON Schema object or boolean schema.
  factory Schema.fromJson(Object json, {SchemaResolver? resolver}) =>
      (resolver ?? SchemaResolver(SchemasSingleton._definitions)).parseSchema(
        json,
      );

  /// Creates a schema using the former convenience constructor.
  ///
  /// In 3.0, [toJson] returns a JSON value because JSON Schema permits boolean
  /// schemas as well as objects.
  factory Schema({
    required String type,
    List<String>? typeUnion,
    String? description,
    Map<String, Schema>? properties,
    Schema? items,
    Object? additionalProperties,
    List<Object?>? enum_,
    List<String>? required,
    List<Schema>? oneOf,
    List<Schema>? anyOf,
    List<Schema>? allOf,
    num? minimum,
    num? maximum,
    num? exclusiveMinimum,
    num? exclusiveMaximum,
    num? multipleOf,
    num? minLength,
    num? maxLength,
    String? pattern,
    String? format,
    num? minItems,
    num? maxItems,
    bool? uniqueItems,
    num? minProperties,
    num? maxProperties,
    Object? constValue = _schemaUnset,
    Object? defaultValue = _schemaUnset,
  }) => Schema.fromJson({
    'type': typeUnion ?? type,
    if (description != null) 'description': description,
    if (properties != null)
      'properties': properties.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    if (items != null) 'items': items.toJson(),
    if (additionalProperties is Schema)
      'additionalProperties': additionalProperties.toJson()
    else if (additionalProperties != null)
      'additionalProperties': additionalProperties,
    if (enum_ != null) 'enum': enum_,
    if (required != null) 'required': required,
    if (oneOf != null) 'oneOf': oneOf.map((schema) => schema.toJson()).toList(),
    if (anyOf != null) 'anyOf': anyOf.map((schema) => schema.toJson()).toList(),
    if (allOf != null) 'allOf': allOf.map((schema) => schema.toJson()).toList(),
    if (minimum != null) 'minimum': minimum,
    if (maximum != null) 'maximum': maximum,
    if (exclusiveMinimum != null) 'exclusiveMinimum': exclusiveMinimum,
    if (exclusiveMaximum != null) 'exclusiveMaximum': exclusiveMaximum,
    if (multipleOf != null) 'multipleOf': multipleOf,
    if (minLength != null) 'minLength': minLength,
    if (maxLength != null) 'maxLength': maxLength,
    if (pattern != null) 'pattern': pattern,
    if (format != null) 'format': format,
    if (minItems != null) 'minItems': minItems,
    if (maxItems != null) 'maxItems': maxItems,
    if (uniqueItems != null) 'uniqueItems': uniqueItems,
    if (minProperties != null) 'minProperties': minProperties,
    if (maxProperties != null) 'maxProperties': maxProperties,
    if (!identical(constValue, _schemaUnset)) 'const': constValue,
    if (!identical(defaultValue, _schemaUnset)) 'default': defaultValue,
  });

  /// Whether this node is a boolean schema (`true` or `false`).
  bool get isBooleanSchema => _json is bool;

  /// An immutable view of the original JSON Schema value.
  Object get rawSchema => _deepUnmodifiable(_json);

  /// The original schema value, preserving references and all keywords.
  Object toJson() => _deepCopy(_json)!;

  /// Validates an instance and returns structured errors and warnings.
  SchemaValidationResult validate(Object? instance, {bool? validateFormats}) {
    final errors = _validatorFor(validateFormats).errors(instance);
    return SchemaValidationResult(
      valid: errors.isEmpty,
      errors: errors.map((error) => error.toString()).toList(),
      warnings: const [],
    );
  }

  bool isValid(Object? instance, {bool? validateFormats}) =>
      _validatorFor(validateFormats).isValid(instance);

  json_schema.CompiledSchema _validatorFor(bool? validateFormats) =>
      _validators.putIfAbsent(validateFormats, () {
        final resolver = _resolver;
        if (resolver == null) {
          return json_schema.JsonSchema.fromJson(_engineSchema).compile(
            options: json_schema.SchemaOptions(
              assertFormats: validateFormats,
              resources: _resources,
            ),
          );
        }
        return resolver
            ._compile(
              _engineSchema,
              validateFormats: validateFormats,
              initialResources: _resources,
            )
            .validator;
      });

  /// Returns a keyword's original value, or `null` if it is absent or null.
  Object? operator [](String keyword) {
    if (_json is Map<String, dynamic> && _json.containsKey(keyword)) {
      final value = _json[keyword];
      return value == null ? null : _deepUnmodifiable(value);
    }
    final value = _schemaView[keyword];
    return value == null ? null : _deepUnmodifiable(value);
  }

  bool get hasType => this['type'] != null;
  String get type {
    final value = _schemaView['type'];
    if (value is String) return value;
    if (value is List && value.isNotEmpty && value.first is String) {
      return value.first as String;
    }
    return '';
  }

  List<String>? get typeUnion {
    final value = _schemaView['type'];
    return value is List ? List<String>.from(value) : null;
  }

  String? get description => this['description'] as String?;
  Map<String, Schema>? get properties => _schemaMap('properties');
  Schema? get items => _schema('items');
  Object? get additionalProperties {
    final value = this['additionalProperties'];
    return value is bool
        ? value
        : value == null
        ? null
        : _wrap(value);
  }

  List<Object?>? get enum_ => _list<Object?>('enum');
  List<String>? get required => _list<String>('required');
  List<Schema>? get oneOf => _schemaList('oneOf');
  List<Schema>? get anyOf => _schemaList('anyOf');
  List<Schema>? get allOf => _schemaList('allOf');
  num? get minimum => this['minimum'] as num?;
  num? get maximum => this['maximum'] as num?;
  num? get exclusiveMinimum => this['exclusiveMinimum'] as num?;
  num? get exclusiveMaximum => this['exclusiveMaximum'] as num?;
  num? get multipleOf => this['multipleOf'] as num?;
  num? get minLength => this['minLength'] as num?;
  num? get maxLength => this['maxLength'] as num?;
  String? get pattern => this['pattern'] as String?;
  String? get format => this['format'] as String?;
  num? get minItems => this['minItems'] as num?;
  num? get maxItems => this['maxItems'] as num?;
  bool? get uniqueItems => this['uniqueItems'] as bool?;
  num? get minProperties => this['minProperties'] as num?;
  num? get maxProperties => this['maxProperties'] as num?;
  Object? get constValue => this['const'];
  Object? get defaultValue => this['default'];
  bool get hasConstValue => _containsKey('const');
  bool get hasDefaultValue => _containsKey('default');

  bool _containsKey(String key) =>
      _json is Map<String, dynamic> && _json.containsKey(key);

  Map<String, dynamic> get _schemaView {
    if (_json is! Map<String, dynamic>) return const {};
    final result = <String, dynamic>{};
    var current = _json;
    var reference = current[r'$ref'];
    final seen = <String>{};
    while (reference is String &&
        reference.startsWith('#/schemas/') &&
        seen.add(reference)) {
      final target = _resolver?._referencedSchema(reference);
      if (target is! Map<String, dynamic>) break;
      for (final entry in target.entries) {
        result.putIfAbsent(entry.key, () => entry.value);
      }
      current = target;
      reference = target[r'$ref'];
    }
    result.addAll(_json);
    return result;
  }

  Schema? _schema(String key) {
    final value = this[key];
    return value == null ? null : _wrap(value);
  }

  Map<String, Schema>? _schemaMap(String key) {
    final value = this[key];
    if (value is! Map) return null;
    return value.map(
      (name, schema) => MapEntry(name.toString(), _wrap(schema)),
    );
  }

  List<T>? _list<T>(String key) {
    final value = this[key];
    return value is List ? List<T>.from(value) : null;
  }

  List<Schema>? _schemaList(String key) {
    final value = this[key];
    if (value is! List) return null;
    return value.map((child) => _wrap(child as Object)).toList();
  }

  Schema _wrap(Object value) =>
      _resolver?.parseSchema(value) ?? Schema.fromJson(value);
}

/// Result of validating one JSON value against a [Schema].
class SchemaValidationResult {
  const SchemaValidationResult({
    required this.valid,
    required this.errors,
    required this.warnings,
  });

  final bool valid;
  bool get isValid => valid;
  final List<String> errors;
  final List<String> warnings;
}

/// Compiles JSON Schema documents and resolves OpenTool's legacy schema names.
///
/// Schemas default to Draft 2020-12. A `$schema` declaration selects a
/// supported dialect. OpenTool references of the form `#/schemas/<name>` are
/// adapted to a local resource provider; standard `$ref` and `$dynamicRef`
/// values are left to the JSON Schema engine.
class SchemaResolver {
  final Map<String, dynamic> _definitions;
  final SchemaReferenceResolver? _referenceResolver;
  final Map<String, Schema> _resolved = {};
  final Set<String> _resolving = {};

  SchemaResolver([Map<String, dynamic>? definitions])
    : this._(definitions ?? const {}, null);

  SchemaResolver.withReferenceResolver({
    Map<String, dynamic>? definitions,
    SchemaReferenceResolver? referenceResolver,
  }) : this._(definitions ?? const {}, referenceResolver);

  SchemaResolver._(this._definitions, this._referenceResolver);

  Object? _referencedSchema(String reference) {
    final name = reference.substring('#/schemas/'.length).split('/').first;
    return _definitions[name.replaceAll('~1', '/').replaceAll('~0', '~')];
  }

  Map<String, Schema> resolveAll() {
    final result = <String, Schema>{};
    for (final name in _definitions.keys) {
      result[name] = _resolveDefinition(name, 'schemas.$name');
    }
    return result;
  }

  Schema parseSchema(Object json, {String path = 'schema'}) {
    try {
      _validateJsonValue(json, path);
      _validateSchemaStructure(json, path);
      final normalized = _normalize(json);
      final compilation = _compile(normalized, path: path);
      return Schema._(_deepCopy(json)!, normalized, compilation.resources, {
        null: compilation.validator,
      }, this);
    } on FormatException catch (error) {
      if (error.message.toString().startsWith(path)) rethrow;
      throw FormatException('$path: ${error.message}');
    } on json_schema.SchemaException catch (error) {
      final location = error.schemaPath.isEmpty ? '' : '#${error.schemaPath}';
      throw FormatException('$path$location: ${error.message}');
    } on json_schema.ReferenceException catch (error) {
      throw FormatException('$path: ${error.message} (${error.reference})');
    } on Object catch (error) {
      throw FormatException('$path: invalid JSON Schema: $error');
    }
  }

  _SchemaCompilation _compile(
    Object normalized, {
    String path = 'schema',
    bool? validateFormats,
    Map<Uri, Object?> initialResources = const {},
  }) {
    final resources = Map<Uri, Object?>.of(initialResources);
    for (final entry in _definitions.entries) {
      final uri = Uri(
        scheme: 'opentool-schema',
        host: 'document',
        pathSegments: ['schemas', entry.key],
      );
      resources.putIfAbsent(uri, () => _normalize(entry.value as Object));
    }

    final attemptedReferences = <Uri>{};
    while (true) {
      try {
        final validator =
            json_schema.JsonSchema.fromJson(
              normalized,
              draft: _selectDraft(normalized, resources),
            ).compile(
              options: json_schema.SchemaOptions(
                assertFormats: validateFormats,
                resources: resources,
              ),
            );
        return _SchemaCompilation(
          validator,
          Map<Uri, Object?>.unmodifiable(resources),
        );
      } on json_schema.ReferenceException catch (error) {
        final uri = error.reference.removeFragment();
        final resolver = _referenceResolver;
        if (resolver == null ||
            resources.containsKey(uri) ||
            !attemptedReferences.add(uri)) {
          rethrow;
        }
        final external = resolver(uri.toString());
        if (external == null || (external is! Map && external is! bool)) {
          rethrow;
        }
        _validateJsonValue(external, '$path<$uri>');
        resources[uri] = _normalize(external);
      }
    }
  }

  json_schema.SchemaDraft _selectDraft(
    Object normalized,
    Map<Uri, Object?> resources,
  ) {
    if (normalized is! Map<String, dynamic> ||
        normalized[r'$schema'] is! String) {
      return json_schema.SchemaDraft.draft202012;
    }
    var identifier = normalized[r'$schema'] as String;
    final seen = <String>{};
    while (seen.add(identifier)) {
      try {
        return json_schema.SchemaDraft.fromUri(identifier);
      } on FormatException {
        final uri = Uri.parse(identifier).removeFragment();
        final resource = resources[uri];
        if (resource is! Map<String, dynamic> ||
            resource[r'$schema'] is! String) {
          return json_schema.SchemaDraft.draft202012;
        }
        identifier = resource[r'$schema'] as String;
      }
    }
    throw FormatException('schema.\$schema: cyclic meta-schema $identifier.');
  }

  void _validateSchemaStructure(Object? schema, String path) {
    if (schema is bool) return;
    if (schema is! Map) {
      throw FormatException('$path: expected a schema object or boolean.');
    }

    if (schema.containsKey('type')) {
      final type = schema['type'];
      if (type is! String &&
          (type is! List ||
              type.isEmpty ||
              type.any((value) => value is! String))) {
        throw FormatException(
          '$path.type: expected a type name or array of type names.',
        );
      }
    }

    for (final keyword in [r'$ref', r'$dynamicRef']) {
      final reference = schema[keyword];
      if (reference is String && reference.startsWith('#/schemas/')) {
        final token = reference.substring('#/schemas/'.length).split('/').first;
        final name = token.replaceAll('~1', '/').replaceAll('~0', '~');
        if (!_definitions.containsKey(name)) {
          throw FormatException(
            '$path.$keyword: schema "$name" was not found.',
          );
        }
      }
    }

    const schemaMapKeywords = {
      r'$defs',
      'definitions',
      'properties',
      'patternProperties',
      'dependentSchemas',
    };
    const schemaListKeywords = {'allOf', 'anyOf', 'oneOf', 'prefixItems'};
    const schemaKeywords = {
      'additionalProperties',
      'unevaluatedProperties',
      'items',
      'additionalItems',
      'unevaluatedItems',
      'contains',
      'propertyNames',
      'not',
      'if',
      'then',
      'else',
      'contentSchema',
    };

    for (final keyword in schemaMapKeywords) {
      final value = schema[keyword];
      if (value is Map) {
        for (final entry in value.entries) {
          _validateSchemaStructure(entry.value, '$path.$keyword.${entry.key}');
        }
      }
    }
    for (final keyword in schemaListKeywords) {
      final value = schema[keyword];
      if (value is List) {
        for (var i = 0; i < value.length; i++) {
          _validateSchemaStructure(value[i], '$path.$keyword[$i]');
        }
      }
    }
    for (final keyword in schemaKeywords) {
      final value = schema[keyword];
      if (value is Map || value is bool) {
        _validateSchemaStructure(value, '$path.$keyword');
      } else if (keyword == 'items' && value is List) {
        for (var i = 0; i < value.length; i++) {
          _validateSchemaStructure(value[i], '$path.items[$i]');
        }
      }
    }
  }

  Schema _resolveDefinition(String name, String path) {
    final cached = _resolved[name];
    if (cached != null) return cached;
    if (!_definitions.containsKey(name)) {
      throw FormatException('$path: schema "$name" was not found.');
    }
    if (!_resolving.add(name)) {
      // Recursive references are valid in modern JSON Schema. Return a raw
      // schema wrapper here; the validator resolves the reference at runtime.
      return parseSchema(_definitions[name], path: path);
    }
    try {
      final schema = parseSchema(_definitions[name], path: path);
      _resolved[name] = schema;
      return schema;
    } finally {
      _resolving.remove(name);
    }
  }

  Object _normalize(Object raw) {
    final normalized = _normalizeValue(raw, 'schema');
    if (normalized is Map && !normalized.containsKey(r'$schema')) {
      return <String, dynamic>{
        r'$schema': json_schema.SchemaDraft.draft202012.metaSchemaUri,
        ...normalized,
      };
    }
    return normalized!;
  }

  Object? _normalizeValue(Object? value, String path) {
    if (value is List) {
      return [
        for (var i = 0; i < value.length; i++)
          _normalizeValue(value[i], '$path[$i]'),
      ];
    }
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        if (entry.key is! String) {
          throw FormatException('$path: object keys must be strings.');
        }
        final key = entry.key as String;
        final child = entry.value;
        if ((key == r'$ref' || key == r'$dynamicRef') && child is String) {
          result[key] = _normalizeOpenToolReference(child);
        } else {
          result[key] = _normalizeIntegerConstraint(
            key,
            _normalizeValue(child, '$path.$key'),
          );
        }
      }
      return result;
    }
    if (value == null || value is String || value is bool) return value;
    if (value is num && value.isFinite) return value;
    throw FormatException('$path: expected a JSON value.');
  }

  Object? _normalizeIntegerConstraint(String keyword, Object? value) {
    const keywords = {
      'minLength',
      'maxLength',
      'minItems',
      'maxItems',
      'minContains',
      'maxContains',
      'minProperties',
      'maxProperties',
    };
    if (keywords.contains(keyword) &&
        value is double &&
        value.isFinite &&
        value == value.truncateToDouble()) {
      return value.toInt();
    }
    return value;
  }

  void _validateJsonValue(Object? value, String path) {
    if (value == null || value is String || value is bool) return;
    if (value is num) {
      if (!value.isFinite) {
        throw FormatException('$path: JSON numbers must be finite.');
      }
      return;
    }
    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        _validateJsonValue(value[i], '$path[$i]');
      }
      return;
    }
    if (value is Map) {
      for (final entry in value.entries) {
        if (entry.key is! String) {
          throw FormatException('$path: object keys must be strings.');
        }
        _validateJsonValue(entry.value, '$path.${entry.key}');
      }
      return;
    }
    throw FormatException('$path: expected a JSON value.');
  }

  String _normalizeOpenToolReference(String reference) {
    const prefix = '#/schemas/';
    if (!reference.startsWith(prefix)) return reference;
    final parts = reference.substring(prefix.length).split('/');
    if (parts.isEmpty || parts.first.isEmpty) return reference;
    final name = parts.first.replaceAll('~1', '/').replaceAll('~0', '~');
    final rest = parts.skip(1).join('/');
    return Uri(
      scheme: 'opentool-schema',
      host: 'document',
      pathSegments: ['schemas', name],
      fragment: rest.isEmpty ? null : '/$rest',
    ).toString();
  }
}

class _SchemaCompilation {
  const _SchemaCompilation(this.validator, this.resources);

  final json_schema.CompiledSchema validator;
  final Map<Uri, Object?> resources;
}

Object? _deepCopy(Object? value) {
  if (value is Map) {
    return <String, dynamic>{
      for (final entry in value.entries)
        entry.key as String: _deepCopy(entry.value),
    };
  }
  if (value is List) return value.map(_deepCopy).toList();
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  throw FormatException('Expected a JSON value, got ${value.runtimeType}.');
}

Object _deepUnmodifiable(Object value) {
  if (value is Map) {
    return Map.unmodifiable(
      value.map((key, entry) => MapEntry(key, _deepUnmodifiable(entry))),
    );
  }
  if (value is List) {
    return List.unmodifiable(value.map((child) => _deepUnmodifiable(child)));
  }
  return value;
}

/// Legacy global schema registry. Prefer [OpenTool.fromJson] or [SchemaResolver]
/// so references stay scoped to their document.
class SchemasSingleton {
  static Map<String, dynamic> _definitions = const {};
  static Map<String, Schema> _schemas = const {};

  @Deprecated(
    'Use OpenTool.fromJson or SchemaResolver for document-local refs.',
  )
  static void initInstance(Map<String, dynamic> schemasJson) {
    _definitions = Map<String, dynamic>.from(schemasJson);
    _schemas = SchemaResolver(_definitions).resolveAll();
  }

  @Deprecated('Use OpenTool.schemas or SchemaResolver for document-local refs.')
  static Map<String, Schema> getInstance() => _schemas;
}
