import 'dart:convert';
import 'dart:io';

import '/src/model/open_tool.dart';
import 'model/schema.dart';

class OpenToolLoader {
  Map<String, dynamic>? schemasJson;

  Future<OpenTool> load(String jsonString) async {
    Map<String, dynamic> openToolMap = jsonDecode(jsonString);
    schemasJson = openToolMap["schemas"];
    if (schemasJson != null) {
        SchemasSingleton.initInstance(schemasJson!);
      }
    OpenTool openTool = OpenTool.fromJson(openToolMap);
    return openTool;
  }

  Future<OpenTool> loadFromFile(String jsonPath) async {
    File file = File(jsonPath);
    String jsonString = await file.readAsString();
    return load(jsonString);
  }
}