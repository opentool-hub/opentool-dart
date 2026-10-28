import 'dart:convert';
import 'dart:io';
import 'model/opentool.dart';

class OpenToolJsonLoader {
  Future<OpenTool> load(String jsonString) async {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('OpenTool document: expected a JSON object.');
    }
    return OpenTool.fromJson(decoded);
  }

  Future<OpenTool> loadFromFile(String jsonPath) async {
    File file = File(jsonPath);
    String jsonString = await file.readAsString();
    return load(jsonString);
  }
}
