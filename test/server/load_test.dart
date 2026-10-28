import 'dart:convert';

import 'package:opentool_dart/src/server/controller.dart';
import 'package:opentool_dart/src/tool/tool.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test(
    'returns an explicit 404 response when tool metadata is absent',
    () async {
      final controller = Controller(
        _MissingMetadataTool(),
        'test',
        onStop: () async {},
      );

      final response = await controller.load(
        Request('GET', Uri.parse('http://localhost/opentool/load')),
      );

      expect(response.statusCode, 404);
      expect(jsonDecode(await response.readAsString()), {
        'code': 'TOOL_NOT_FOUND',
        'message': 'Tool metadata not found',
      });
    },
  );
}

class _MissingMetadataTool extends Tool {
  @override
  Future<Map<String, dynamic>> call(
    String name,
    Map<String, dynamic>? arguments,
  ) async => {};
}
