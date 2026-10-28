import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:opentool_dart/opentool_client.dart';
import 'package:test/test.dart';

void main() {
  group('OpenToolClient.load', () {
    test('loads a valid document with a union schema', () async {
      final client = _clientWithResponse(
        200,
        jsonEncode(
          _document(
            schema: {
              'type': ['string', 'null'],
            },
          ),
        ),
      );

      final openTool = await client.load();

      expect(openTool!.functions.single.parameters.single.schema.type, [
        'string',
        'null',
      ]);
    });

    test(
      'returns null only for the explicit tool not found response',
      () async {
        final client = _clientWithResponse(
          404,
          jsonEncode({
            'code': 'TOOL_NOT_FOUND',
            'message': 'Tool metadata not found',
          }),
        );

        expect(await client.load(), isNull);
      },
    );

    test('propagates signature parsing errors', () async {
      final client = _clientWithResponse(
        200,
        jsonEncode(
          _document(
            schema: {
              'type': ['string', 1],
            },
          ),
        ),
      );

      await expectLater(
        client.load(),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('functions[0].parameters[0].schema.type'),
          ),
        ),
      );
    });

    test('does not treat an unrelated HTTP 404 as a missing tool', () async {
      final client = _clientWithResponse(404, '{"error":"route not found"}');

      await expectLater(
        client.load(),
        throwsA(isA<OpenToolServerCallException>()),
      );
    });
  });
}

OpenToolClient _clientWithResponse(int statusCode, String body) {
  final client = OpenToolClient(toolHost: 'localhost', toolPort: 8080);
  client.dio.httpClientAdapter = _StaticResponseAdapter(statusCode, body);
  return client;
}

Map<String, dynamic> _document({required Map<String, dynamic> schema}) => {
  'opentool': '1.0.0',
  'info': {'title': 'Client load test', 'version': '1.0.0'},
  'functions': [
    {
      'name': 'inspect',
      'description': 'Inspect a value.',
      'parameters': [
        {'name': 'value', 'schema': schema},
      ],
    },
  ],
};

class _StaticResponseAdapter implements HttpClientAdapter {
  final int statusCode;
  final String body;

  _StaticResponseAdapter(this.statusCode, this.body);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}
