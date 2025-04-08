# opentool_dart

[English](README.md) · 中文

一个用于 Dart 的 OpenTool JSON 规范解析器，带有ToolDrivers。

灵感来源于OpenAPI、OpenRPC和OpenAI的 `function calling`示例。

## 特性

- 加载 OpenTool JSON 文件，并转换为 Dart 对象。 见 [OpenTool规范](opentool-specification-cn.md).
- 提供用于支持 LLM 函数调用的 ToolDriver 抽象类。
- 支持的JSON规范/驱动：
  - HTTP: [OpenAPI3/HTTP](https://github.com/djbird2046/openapi_dart)
  - JSON-RPC: [OpenRPC/JSON-RPC](https://github.com/djbird2046/openrpc_dart)
  - Modbus: [OpenModbus/RTU/ASCII/TCP/UDP](https://github.com/djbird2046/openmodbus_dart)
  - dll/dylib: [OpenDyn](https://github.com/LiteVar/opendyn_dart)
  - Serial Port
  - MCP：stdio, [Tools](https://modelcontextprotocol.io/docs/concepts/tools)

## 用法

根据 `/example/opentool_dart_example.dart` 示例进行操作。

- 从 JSON 字符串加载
```dart
Future<void> main() async {
  String jsonString = "{...OpenTool String...}";
  OpenToolLoader openToolLoader = OpenToolLoader();
  OpenTool openTool = await openToolLoader.load(jsonString);
}
```
- 从 JSON 文件加载
```dart
Future<void> main() async {
  String jsonPath = "$currentWorkingDirectory/example/json/$jsonFileName";
  OpenToolLoader openToolLoader = OpenToolLoader();
  OpenTool openTool = await openToolLoader.loadFromFile(jsonPath); 
}
```

## 注意

### 串口连接

- 串口连接的库 `libserialport` 依赖环境变量 `LIBSERIALPORT_PATH`，设置为文件 `libs/serial_port/windows/libserialport.dll`(Windows) or `libs/serial_port/macos/libserialport.dylib`(macOS)
