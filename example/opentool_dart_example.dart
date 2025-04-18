import 'dart:io';
import 'package:opentool_dart/opentool_dart.dart';

void main() async {
  List<String> jsonFileNameList = [
    // "mock_tool.json",
    "opentool-database-example.json",
    "opentool-weather-example.json"
  ];

  String currentWorkingDirectory = Directory.current.path;
  jsonFileNameList.forEach((jsonFileName) async {
    print("FILE_NAME: $jsonFileName");
    String jsonPath = "$currentWorkingDirectory${Platform.pathSeparator}example${Platform.pathSeparator}json${Platform.pathSeparator}opentool${Platform.pathSeparator}$jsonFileName";
    OpenToolLoader openToolLoader = OpenToolLoader();
    OpenTool openTool = await openToolLoader.loadFromFile(jsonPath);
    print("openTool: ${openTool.toJson()}");
    print("title: ${openTool.info.title}");
  });
}
