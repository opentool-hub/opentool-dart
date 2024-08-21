# opentool_dart

English · [中文](README-zh_CN.md)

An OpenTool JSON Spec Parser for dart with ToolDrivers.

Inspired by OpenAPI, OpenRPC, and OpenAI `function calling` example.

## Features

- Load OpenTool json file, and convert to dart object. See [OpenTool Specification](opentool-specification-en.md).
- ToolDriver abstract class for LLM function calling support.
- Support JSON Specification/Driver: [OpenAPI3/HTTP](https://github.com/djbird2046/openapi_dart), [OpenRPC/JsonRPC](https://github.com/djbird2046/openrpc_dart), [OpenModbus/RTU/ASCII/TCP/UDP](https://github.com/djbird2046/openmodbus_dart)

## Usage

According to `/example/opentool_dart_example.dart`.

- From JSON String
```dart
Future<void> main() async {
  String jsonString = "{...OpenTool String...}";
  OpenToolLoader openToolLoader = OpenToolLoader();
  OpenTool openTool = await openToolLoader.load(jsonString);
}
```
- From JSON File
```dart
Future<void> main() async {
  String jsonPath = "$currentWorkingDirectory/example/json/$jsonFileName";
  OpenToolLoader openToolLoader = OpenToolLoader();
  OpenTool openTool = await openToolLoader.loadFromFile(jsonPath); 
}
```