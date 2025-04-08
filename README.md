# opentool_dart

English · [中文](README-zh_CN.md)

An OpenTool JSON Spec Parser for dart with ToolDrivers.

Inspired by OpenAPI, OpenRPC, and OpenAI `function calling` example.

## Features

- Load OpenTool json file, and convert to dart object. See [OpenTool Specification](opentool-specification-en.md).
- ToolDriver abstract class for LLM function calling support.
- Support JSON Specification/Driver: 
  - HTTP: [OpenAPI3/HTTP](https://github.com/djbird2046/openapi_dart)
  - JSON-RPC: [OpenRPC/JSON-RPC](https://github.com/djbird2046/openrpc_dart)
  - Modbus: [OpenModbus/RTU/ASCII/TCP/UDP](https://github.com/djbird2046/openmodbus_dart)
  - dll/dylib: [OpenDyn](https://github.com/LiteVar/opendyn_dart)
  - Serial Port
  - MCP：stdio, [Tools](https://modelcontextprotocol.io/docs/concepts/tools)

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

## Note

### Serial Port

- The lib `libserialport` need environmentVariable `LIBSERIALPORT_PATH` to be set to the path of the `libs/serial_port/windows/libserialport.dll`(Windows) or `libs/serial_port/macos/libserialport.dylib`(macOS)
