import 'dart:convert';

import 'package:opentool_dart/opentool_schema.dart';
import 'package:test/test.dart';

void main() {
  group('OpenTool schema parsing', () {
    test(
      'loads the checked-in tool document through OpenToolJsonLoader',
      () async {
        final loader = OpenToolJsonLoader();
        final openTool = await loader.loadFromFile(
          'example/server/mock_tool.json',
        );

        expect(openTool.functions, isNotEmpty);
        expect(openTool.schemas, hasLength(3));
        expect(openTool.functions.first.return_!.schema.type, 'integer');
        expect(loader.schemasJson, hasLength(3));
      },
    );

    test('loads schemas with forward references', () {
      final openTool = OpenTool.fromJson(
        _document(
          schema: {r'$ref': '#/schemas/First'},
          schemas: {
            'First': {r'$ref': '#/schemas/Later'},
            'Later': {
              'type': 'object',
              'properties': {
                'label': {'type': 'string'},
              },
            },
          },
        ),
      );

      expect(openTool.functions.single.parameters.single.schema.type, 'object');
      expect(
        openTool
            .functions
            .single
            .parameters
            .single
            .schema
            .properties!['label']!
            .type,
        'string',
      );
      expect(openTool.schemas!['First']!.type, 'object');
    });

    test('round trips union types and composition keywords', () {
      final schema = Schema.fromJson({
        'type': ['string', 'null'],
        'oneOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
        'anyOf': [
          {
            'enum': ['low', 'high'],
          },
        ],
        'allOf': [
          {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
            },
          },
        ],
        'additionalProperties': {'type': 'integer'},
      });

      expect(schema.type, 'string');
      expect(schema.typeUnion, ['string', 'null']);
      expect(schema.oneOf, hasLength(2));
      expect(schema.anyOf, hasLength(1));
      expect(schema.allOf, hasLength(1));
      expect(schema.toJson(), {
        'type': ['string', 'null'],
        'additionalProperties': {'type': 'integer'},
        'oneOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
        'anyOf': [
          {
            'enum': ['low', 'high'],
          },
        ],
        'allOf': [
          {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
            },
          },
        ],
      });
    });

    test('round trips common JSON Schema constraints', () {
      final json = {
        'type': ['integer', 'number', 'null'],
        'minimum': -10,
        'maximum': 100.5,
        'exclusiveMinimum': -9.5,
        'exclusiveMaximum': 99,
        'multipleOf': 0.25,
        'minLength': 1,
        'maxLength': 32.0,
        'pattern': r'^[a-z]+$',
        'format': 'custom-format',
        'minItems': 0,
        'maxItems': 12,
        'uniqueItems': true,
        'minProperties': 1,
        'maxProperties': 8,
        'const': {
          'kind': 'fixed',
          'values': [1, true, null],
        },
        'default': ['fallback', null],
      };

      final schema = Schema.fromJson(
        jsonDecode(jsonEncode(json)) as Map<String, dynamic>,
      );

      expect(schema.minimum, -10);
      expect(schema.maximum, 100.5);
      expect(schema.exclusiveMinimum, -9.5);
      expect(schema.exclusiveMaximum, 99);
      expect(schema.multipleOf, 0.25);
      expect(schema.minLength, 1);
      expect(schema.maxLength, 32.0);
      expect(schema.pattern, r'^[a-z]+$');
      expect(schema.format, 'custom-format');
      expect(schema.minItems, 0);
      expect(schema.maxItems, 12);
      expect(schema.uniqueItems, isTrue);
      expect(schema.minProperties, 1);
      expect(schema.maxProperties, 8);
      expect(schema.toJson(), json);
    });

    test('preserves explicit null const and default values', () {
      final schema = Schema.fromJson({'const': null, 'default': null});

      expect(schema.hasConstValue, isTrue);
      expect(schema.constValue, isNull);
      expect(schema.hasDefaultValue, isTrue);
      expect(schema.defaultValue, isNull);
      expect(schema.toJson(), {'const': null, 'default': null});
    });

    test('accepts integral JSON numbers for integer schemas', () {
      final schema = Schema.fromJson({
        'type': 'integer',
        'enum': [1.0],
        'minLength': 2.0,
      });

      expect(schema.enum_, [1.0]);
      expect(schema.minLength, 2.0);
      expect((schema.toJson() as Map<String, dynamic>)['minLength'], 2.0);
    });

    test(
      'loads constrained schemas in a complete OpenTool description',
      () async {
        final expectedSchema = {
          'type': 'string',
          'minLength': 2,
          'maxLength': 40,
          'pattern': r'^[a-zA-Z0-9_-]+$',
          'format': 'custom-id',
          'default': 'tool_123',
        };
        final input = _document(schema: expectedSchema);
        final openTool = await OpenToolJsonLoader().load(jsonEncode(input));

        expect(
          openTool.functions.single.parameters.single.schema.toJson(),
          expectedSchema,
        );
        expect(
          (openTool.toJson()['functions'] as List)
              .single['parameters']
              .single['schema'],
          expectedSchema,
        );
      },
    );

    test('reports invalid constraint value types with their JSON paths', () {
      final invalidSchemas = <Map<String, dynamic>>[
        {'minimum': '1'},
        {'multipleOf': 0},
        {'minLength': -1},
        {'maxItems': 1.5},
        {'pattern': 3},
        {'format': null},
        {'uniqueItems': 'true'},
        {'minProperties': false},
        {'const': Object()},
        {
          'default': [
            {'invalid': Object()},
          ],
        },
      ];

      for (final invalid in invalidSchemas) {
        final error = expectFormatException(
          () => SchemaResolver().parseSchema(
            invalid,
            path: 'functions[0].parameters[0].schema',
          ),
        );
        expect(error.message, contains('functions[0].parameters[0].schema'));
        expect(error.message, contains(invalid.keys.single));
      }
    });

    test('preserves constraints on referenced schemas with a description', () {
      final openTool = OpenTool.fromJson(
        _document(
          schema: {r'$ref': '#/schemas/Value', 'description': 'A value.'},
          schemas: {
            'Value': {
              'type': 'number',
              'minimum': 1,
              'maximum': 10,
              'multipleOf': 0.5,
            },
          },
        ),
      );

      expect(openTool.schemas!['Value']!.minimum, 1);
      final parameterSchema =
          openTool.functions.single.parameters.single.schema;
      expect(parameterSchema.type, 'number');
      expect(parameterSchema.toJson(), {
        r'$ref': '#/schemas/Value',
        'description': 'A value.',
      });
    });

    test('preserves unknown extension keywords', () {
      final schema = Schema.fromJson({
        'type': 'string',
        'x-vendor-hint': {'ui': 'short-text'},
      });

      expect(schema.toJson(), {
        'type': 'string',
        'x-vendor-hint': {'ui': 'short-text'},
      });
    });

    test('reports unresolved references with the function parameter path', () {
      final error = expectFormatException(
        () => OpenTool.fromJson(
          _document(schema: {r'$ref': '#/schemas/Missing'}),
        ),
      );

      expect(
        error.message,
        contains('functions[0].parameters[0].schema.\$ref'),
      );
      expect(error.message, contains('Missing'));
    });

    test('does not reuse references from a previously parsed document', () {
      OpenTool.fromJson(
        _document(
          schema: {r'$ref': '#/schemas/Value'},
          schemas: {
            'Value': {'type': 'string'},
          },
        ),
      );

      final error = expectFormatException(
        () =>
            OpenTool.fromJson(_document(schema: {r'$ref': '#/schemas/Value'})),
      );

      expect(error.message, contains('Value'));
      expect(error.message, contains('not found'));
    });

    test('keeps the legacy Schema type and singleton APIs working', () {
      final String legacyType = Schema.fromJson({'type': 'string'}).type;
      expect(legacyType, 'string');

      // ignore: deprecated_member_use
      SchemasSingleton.initInstance({
        'LegacyValue': {'type': 'integer'},
      });
      expect(
        Schema.fromJson({r'$ref': '#/schemas/LegacyValue'}).type,
        'integer',
      );
    });

    test('supports recursive references', () {
      final openTool = OpenTool.fromJson(
        _document(
          schema: {r'$ref': '#/schemas/Node'},
          schemas: {
            'Node': {
              'type': 'object',
              'properties': {
                'next': {r'$ref': '#/schemas/Node'},
              },
            },
          },
        ),
      );

      final schema = openTool.functions.single.parameters.single.schema;
      expect(
        schema.isValid({
          'next': {'next': {}},
        }),
        isTrue,
      );
      expect(schema.isValid({'next': 1}), isFalse);
    });

    test('supports boolean schemas and Draft 2020-12 tuple validation', () {
      final allowAnything = Schema.fromJson(true);
      final denyAnything = Schema.fromJson(false);
      final tuple = Schema.fromJson({
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        'prefixItems': [
          {'type': 'integer'},
          {'type': 'string'},
        ],
        'items': false,
      });

      expect(allowAnything.toJson(), isTrue);
      expect(allowAnything.isValid(null), isTrue);
      expect(denyAnything.toJson(), isFalse);
      expect(denyAnything.isValid(null), isFalse);
      expect(tuple.isValid([1, 'name']), isTrue);
      expect(tuple.isValid([1, 'name', true]), isFalse);
      expect(tuple.isValid([1, 2]), isFalse);
    });

    test(r'supports local standard references through $defs', () {
      final schema = Schema.fromJson({
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        r'$defs': {
          'positiveInteger': {'type': 'integer', 'minimum': 1},
        },
        r'$ref': r'#/$defs/positiveInteger',
      });

      expect(schema.isValid(2), isTrue);
      expect(schema.isValid(0), isFalse);
      expect(schema.toJson(), {
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        r'$defs': {
          'positiveInteger': {'type': 'integer', 'minimum': 1},
        },
        r'$ref': r'#/$defs/positiveInteger',
      });
    });

    test('rejects every instance for an empty enum', () {
      final schema = Schema.fromJson({'enum': []});

      for (final instance in [null, false, 0, 'value', [], {}]) {
        expect(schema.isValid(instance), isFalse);
      }
    });

    test(r'treats a pointer $dynamicRef as a static reference', () {
      final schema = Schema.fromJson({
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        r'$id': 'https://test.example/dynamic-ref/root',
        r'$ref': 'list',
        r'$defs': {
          'list': {
            r'$id': 'list',
            'type': 'array',
            'items': {r'$dynamicRef': r'#/$defs/items'},
            r'$defs': {
              'items': {r'$dynamicAnchor': 'items', 'type': 'number'},
            },
          },
        },
      });

      expect(schema.isValid([24, 42]), isTrue);
      expect(schema.isValid(['foo', 'bar']), isFalse);
    });

    test(r'resolves $dynamicRef targets that are boolean schemas', () {
      final schema = Schema.fromJson({
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        r'$defs': {'allow': true, 'deny': false},
        'properties': {
          'allow': {r'$dynamicRef': r'#/$defs/allow'},
          'deny': {r'$dynamicRef': r'#/$defs/deny'},
        },
      });

      expect(schema.isValid({'allow': 1}), isTrue);
      expect(schema.isValid({'deny': 1}), isFalse);
    });

    test(r'resolves dynamic anchors across nested schema resources', () {
      final schema = Schema.fromJson({
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        r'$id': 'https://test.example/dynamic-scope/base',
        r'$ref': r'first#/$defs/stuff',
        r'$defs': {
          'first': {
            r'$id': 'first',
            r'$defs': {
              'stuff': {r'$ref': r'second#/$defs/stuff'},
              'length': {'maxLength': 1},
            },
          },
          'second': {
            r'$id': 'second',
            r'$defs': {
              'stuff': {r'$ref': r'third#/$defs/stuff'},
              'length': {r'$dynamicAnchor': 'length', 'maxLength': 2},
            },
          },
          'third': {
            r'$id': 'third',
            r'$defs': {
              'stuff': {r'$dynamicRef': '#length'},
              'length': {r'$dynamicAnchor': 'length', 'maxLength': 3},
            },
          },
        },
      });

      expect(schema.isValid('hi'), isTrue);
      expect(schema.isValid('hey'), isFalse);
    });

    test(r'resolves a nested $ref after applying the nested $id', () {
      final schema = Schema.fromJson({
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        r'$id': 'https://example.com/draft2020-12/ref-and-id3/base.json',
        r'$ref': 'nested/foo.json',
        r'$defs': {
          'foo': {r'$id': 'nested/foo.json', r'$ref': './bar.json'},
          'bar': {r'$id': 'nested/bar.json', 'type': 'number'},
        },
      });

      expect(schema.isValid(5), isTrue);
      expect(schema.isValid('a'), isFalse);
    });

    test('resolves an absolute path reference to a nested resource', () {
      final schema = Schema.fromJson({
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        r'$id': 'http://example.com/ref/absref.json',
        r'$defs': {
          'a': {
            r'$id': 'http://example.com/ref/absref/foobar.json',
            'type': 'number',
          },
          'b': {
            r'$id': 'http://example.com/absref/foobar.json',
            'type': 'string',
          },
        },
        r'$ref': '/absref/foobar.json',
      });

      expect(schema.isValid('foo'), isTrue);
      expect(schema.isValid(12), isFalse);
    });

    test('does not mark nested array items as evaluated at the root', () {
      final schema = Schema.fromJson({
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        'prefixItems': [
          {
            'prefixItems': [
              true,
              {'type': 'string'},
            ],
          },
        ],
        'unevaluatedItems': false,
      });

      expect(
        schema.isValid([
          ['foo', 'bar'],
        ]),
        isTrue,
      );
      expect(
        schema.isValid([
          ['foo', 'bar'],
          'bar',
        ]),
        isFalse,
      );
    });

    test('applies vocabularies declared by a custom meta-schema', () {
      const noValidationMeta = 'https://schemas.example.test/no-validation';
      const optionalVocabularyMeta =
          'https://schemas.example.test/optional-vocabulary';
      final resolver = SchemaResolver.withReferenceResolver(
        referenceResolver: (uri) => switch (uri) {
          noValidationMeta => {
            r'$schema': 'https://json-schema.org/draft/2020-12/schema',
            r'$id': noValidationMeta,
            r'$vocabulary': {
              'https://json-schema.org/draft/2020-12/vocab/applicator': true,
              'https://json-schema.org/draft/2020-12/vocab/core': true,
            },
            r'$dynamicAnchor': 'meta',
            'allOf': [
              {
                r'$ref':
                    'https://json-schema.org/draft/2020-12/meta/applicator',
              },
              {r'$ref': 'https://json-schema.org/draft/2020-12/meta/core'},
            ],
          },
          optionalVocabularyMeta => {
            r'$schema': 'https://json-schema.org/draft/2020-12/schema',
            r'$id': optionalVocabularyMeta,
            r'$vocabulary': {
              'https://json-schema.org/draft/2020-12/vocab/validation': true,
              'https://json-schema.org/draft/2020-12/vocab/core': true,
              'https://schemas.example.test/vocab/extension': false,
            },
            r'$dynamicAnchor': 'meta',
            'allOf': [
              {
                r'$ref':
                    'https://json-schema.org/draft/2020-12/meta/validation',
              },
              {r'$ref': 'https://json-schema.org/draft/2020-12/meta/core'},
            ],
          },
          _ => null,
        },
      );
      final noValidation = resolver.parseSchema({
        r'$schema': noValidationMeta,
        'properties': {
          'blocked': false,
          'number': {'minimum': 10},
        },
      });
      final optionalVocabulary = resolver.parseSchema({
        r'$schema': optionalVocabularyMeta,
        'type': 'number',
      });

      expect(noValidation.isValid({'blocked': 'value'}), isFalse);
      expect(noValidation.isValid({'number': 1}), isTrue);
      expect(optionalVocabulary.isValid('value'), isFalse);
      expect(optionalVocabulary.isValid(20), isTrue);
    });

    test('treats content keywords as annotations in Draft 2020-12', () {
      final schema = Schema.fromJson({
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        'contentMediaType': 'application/json',
        'contentEncoding': 'base64',
        'contentSchema': {
          'type': 'object',
          'required': ['foo'],
        },
      });

      expect(schema.isValid('e30='), isTrue);
      expect(schema.isValid('eyJmb28iOiAiYmFyIn0='), isTrue);
    });

    test('loads boolean schemas as function parameters', () {
      final openTool = OpenTool.fromJson(_document(schema: false));
      final schema = openTool.functions.single.parameters.single.schema;

      expect(schema.isBooleanSchema, isTrue);
      expect(schema.isValid('anything'), isFalse);
      expect(
        (openTool.toJson()['functions'] as List)
            .single['parameters']
            .single['schema'],
        isFalse,
      );
    });

    test('validates conditionals and unevaluated properties', () {
      final schema = Schema.fromJson({
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        'allOf': [
          {
            'if': {
              'properties': {
                'kind': {'const': 'business'},
              },
              'required': ['kind'],
            },
            'then': {
              'required': ['taxId'],
            },
            'else': {
              'required': ['name'],
            },
          },
          {
            'properties': {
              'kind': {'type': 'string'},
              'taxId': {'type': 'string'},
              'name': {'type': 'string'},
            },
          },
        ],
        'unevaluatedProperties': false,
      });

      expect(schema.isValid({'kind': 'business', 'taxId': '123'}), isTrue);
      expect(schema.isValid({'kind': 'person', 'name': 'Ada'}), isTrue);
      expect(schema.isValid({'kind': 'business', 'name': 'Ada'}), isFalse);
      expect(
        schema.isValid({'kind': 'person', 'name': 'Ada', 'extra': true}),
        isFalse,
      );
    });

    test('supports the declared Draft 4 dialect', () {
      final schema = Schema.fromJson({
        r'$schema': 'http://json-schema.org/draft-04/schema#',
        'type': 'number',
        'minimum': 3,
        'exclusiveMinimum': true,
      });

      expect(schema.isValid(3), isFalse);
      expect(schema.isValid(4), isTrue);
      expect(
        (schema.toJson() as Map<String, dynamic>)[r'$schema'],
        'http://json-schema.org/draft-04/schema#',
      );
    });

    test('resolves registered external schema resources', () {
      final resolver = SchemaResolver.withReferenceResolver(
        referenceResolver: (reference) {
          if (reference != 'https://schemas.example.test/positive-integer') {
            return null;
          }
          return {'type': 'integer', 'minimum': 1};
        },
      );
      final schema = resolver.parseSchema({
        r'$ref': 'https://schemas.example.test/positive-integer',
      });

      expect(schema.isValid(4), isTrue);
      expect(schema.isValid(0), isFalse);
    });
  });
}

FormatException expectFormatException(void Function() action) {
  try {
    action();
  } on FormatException catch (error) {
    return error;
  }
  fail('Expected a FormatException.');
}

Map<String, dynamic> _document({
  required Object schema,
  Map<String, dynamic>? schemas,
}) => {
  'opentool': '1.0.0',
  'info': {'title': 'Schema test', 'version': '1.0.0'},
  'functions': [
    {
      'name': 'inspect',
      'description': 'Inspect a value.',
      'parameters': [
        {'name': 'value', 'schema': schema},
      ],
    },
  ],
  if (schemas != null) 'schemas': schemas,
};
