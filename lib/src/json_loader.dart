import 'dart:convert';
import 'dart:io';
import 'model/opentool.dart';
import 'model/schema.dart';

class OpenToolJsonLoader {
  /// Retained for compatibility with callers that inspect loaded definitions.
  Map<String, dynamic>? schemasJson;

  Future<OpenTool> load(String jsonString) async {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('OpenTool document: expected a JSON object.');
    }
    final rawSchemas = decoded['schemas'];
    if (rawSchemas != null && rawSchemas is! Map<String, dynamic>) {
      throw const FormatException('schemas: expected an object.');
    }
    schemasJson = rawSchemas as Map<String, dynamic>?;

    final openTool = OpenTool.fromJson(decoded);
    if (schemasJson != null) {
      // ignore: deprecated_member_use
      SchemasSingleton.initInstance(schemasJson!);
    }
    return openTool;
  }

  Future<OpenTool> loadFromFile(String jsonPath) async {
    File file = File(jsonPath);
    String jsonString = await file.readAsString();
    return load(jsonString);
  }
}
