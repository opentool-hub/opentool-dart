# OpenTool SDK for Dart

[English](README.md) | 中文

OpenTool 的 Dart SDK 同时提供轻量级 Shelf Server、HTTP/JSON-RPC Client 以及 JSON 规范解析器，方便在纯 Dart 环境中托管或调用 OpenTool 兼容的 Agent。

## 特性

- `OpenToolServer` 基于自定义 `Tool` 实现暴露 `/opentool` JSON-RPC 端点。
- `OpenToolClient` 封装版本查询、同步调用、SSE 流式调用、元数据加载与远程停机。
- `OpenToolJsonLoader` 解析 OpenTool JSON 规范（例如 `json/` 目录里的示例），自动解析 `$ref` 并生成强类型对象。
- `example/server` 与 `example/client` 展示包含流式输出的完整 CRUD Tool。

## 环境要求

- Dart SDK `>=3.8.0 <4.0.0`
- 如需启用 HTTP Bearer 校验，可通过 `--opentoolServerApiKeys` 传入 API Key。

## 安装

使用命令添加依赖：

```sh
dart pub add opentool_dart
```

或直接修改 `pubspec.yaml`：

```yaml
dependencies:
  opentool_dart: ^2.0.0
```

执行 `dart pub get` 同步依赖。

## 快速上手

### 实现 Tool

```dart
import 'dart:io' as io;
import 'package:opentool_dart/opentool_dart.dart';

class MockTool extends Tool {
  final MockUtil mockUtil = MockUtil();

  @override
  Future<Map<String, dynamic>> call(String name, Map<String, dynamic>? arguments) async {
    if (name == 'count') {
      return {'count': mockUtil.count()};
    }
    return FunctionNotSupportedException(functionName: name).toJson();
  }

  @override
  Future<void> streamCall(String name, Map<String, dynamic>? arguments, void Function(String, Map<String, dynamic>) sendEvent) async {
    if (name == 'sequentiallyRead') {
      mockUtil.sequentiallyRead((data) => sendEvent(EventType.DATA, {'data': data}));
      sendEvent(EventType.DONE, {});
    } else {
      sendEvent(EventType.ERROR, FunctionNotSupportedException(functionName: name).toJson());
    }
  }

  @override
  Future<OpenTool?> load() async {
    final path = '${io.Directory.current.path}/example/server/mock_tool.json';
    return OpenToolJsonLoader().loadFromFile(path);
  }
}
```

### 启动 Server

```sh
dart run example/server/main.dart \
  --opentoolServerTag 1.0.0 \
  --opentoolServerHost 0.0.0.0 \
  --opentoolServerPort 17001 \
  --opentoolServerApiKeys your-key
```

通过 `CliArguments.addCustomOption` / `addCustomMultiOption` 可以按需注入业务自定义参数，`Tool.init` 会在 Server 启动前收到解析结果。

### 在 Dart 中调用

```dart
Future<void> main() async {
  final client = OpenToolClient(toolHost: HostType.LOCALHOST, toolPort: 17001, toolApiKey: 'your-key');
  final version = await client.version();
  final response = await client.call(FunctionCall(id: uniqueId(), name: 'count', arguments: {}));
  await client.streamCall(
    FunctionCall(id: uniqueId(), name: 'sequentiallyRead', arguments: {}),
    (event, toolReturn) => print('$event ${toolReturn.result}'),
  );
  await client.stop();
}
```

## CLI 与 HTTP 参考

- 默认前缀 `/opentool`，包含 `GET /version`、`POST /call`、`POST /streamCall`、`GET /load`、`POST /stop`。
- 内置 CLI 参数：`--opentoolServerTag`、`--opentoolServerHost`、`--opentoolServerPort`、可重复的 `--opentoolServerApiKeys`，亦可扩展自定义参数。
- 流式返回采用 Server-Sent Events，事件顺序为 `start` → 多次 `data`/`error` → 流关闭即 `done`。

## JSON 规范加载器

- 推荐将规范文件放在 `json/`（示例：`database-example.json`、`weather-example.json`）。
- 使用 `OpenToolJsonLoader().loadFromFile(path)` 或 `load(jsonString)` 注入 `OpenTool` 对象与 schema 图。
- 完整字段定义请参考 [OpenTool 规范](https://github.com/opentool-hub/opentool-spec)。

## 开发与测试

- 安装依赖：`dart pub get`。
- 代码检查：`dart analyze`；格式化：`dart format lib example json`。
- 新增测试放在 `test/`，使用 `dart test` 运行；必要时补充集成示例并记录依赖数据。
- 如新增 CLI 参数或接口，请同步更新 `README.md`，方便协同开发者对齐。
