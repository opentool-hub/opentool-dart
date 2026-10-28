import 'package:opentool_dart/opentool_schema.dart';
import 'package:test/test.dart';

void main() {
  group('OpenTool schema parsing', () {
    test(
      'loads the checked-in tool document through OpenToolJsonLoader',
      () async {
        final openTool = await OpenToolJsonLoader().loadFromFile(
          'example/server/mock_tool.json',
        );

        expect(openTool.functions, isNotEmpty);
        expect(openTool.schemas, hasLength(3));
        expect(openTool.functions.first.return_!.schema.type, 'integer');
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

      expect(schema.type, ['string', 'null']);
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

    test('reports unsupported keywords with their schema path', () {
      final error = expectFormatException(
        () => Schema.fromJson({'type': 'string', 'pattern': r'^[a-z]+$'}),
      );

      expect(
        error.message,
        contains('schema: unsupported schema keyword "pattern"'),
      );
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

    test('reports recursive references clearly', () {
      final error = expectFormatException(
        () => OpenTool.fromJson(
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
        ),
      );

      expect(error.message, contains('recursive schema reference'));
      expect(error.message, contains('#/schemas/Node'));
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
  required Map<String, dynamic> schema,
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
