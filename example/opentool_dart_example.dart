import 'dart:io';
import 'package:opentool_dart/opentool_dart.dart';

void main() async {
  List<String> jsonFileNameList = [
    "mock_tool.json"
  ];

  String currentWorkingDirectory = Directory.current.path;
  jsonFileNameList.forEach((jsonFileName) async {
    print("FILE_NAME: $jsonFileName");
    String jsonPath = "$currentWorkingDirectory${Platform.pathSeparator}example${Platform.pathSeparator}custom_driver${Platform.pathSeparator}$jsonFileName";
    OpenToolLoader openToolLoader = OpenToolLoader();
    OpenTool openTool = await openToolLoader.loadFromFile(jsonPath);
    print("title: ${openTool.info.title}");
  });
}
