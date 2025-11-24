# OpenTool SDK for Dart

[English](README.md) | 中文

OpenTool 的 Dart SDK 提供搭建或消费 OpenTool Tool 所需的全部积木：基于 Shelf 的 HTTP/JSON-RPC 服务器、支持同步 + SSE 的 HTTP 客户端，以及 JSON Schema 加载器，全部采用纯 Dart 实现，方便在任意 Dart VM 环境部署。

## 库入口

- `package:opentool_dart/opentool_server.dart` — Server 运行时、CLI 解析器与 `Tool` 基类。
- `package:opentool_dart/opentool_client.dart` — HTTP/JSON-RPC 客户端、DTO 与 LLM 数据结构。
- `package:opentool_dart/opentool_schema.dart` — JSON 规范模型与加载器。

## 特性

- `OpenToolServer` 基于自定义 `Tool` 暴露 `/opentool` JSON-RPC 端点，并可选开启 API Key 鉴权。
- `OpenToolClient` 覆盖版本查询、`call`、SSE `streamCall`、`load` 与远程 `stop`。
- `OpenToolJsonLoader` 解析 `json/` 或 `example/json-example` 中的 OpenTool 规范并处理 `$ref`。
- `example/server` 与 `example/client` 演示 CRUD、流式读取，以及 `CliArguments` 自定义参数的注入流程。

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
import 'package:opentool_dart/opentool_server.dart';

class MockTool extends Tool {
  final MockUtil mockUtil = MockUtil();

  @override
  Future<Map<String, dynamic>?> init(Map<String, dynamic>? cliArgs) async {
    final seeds = cliArgs?["newValues"] as List<String>?;
    seeds?.forEach(mockUtil.create);
    return cliArgs;
  }

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
  --opentoolServerPort 17002 \
  --opentoolServerApiKeys your-key \
  --newValues Foo \
  --newValues Bar
```

`CliArguments` 会把这些参数传递给 `Tool.init`，可用于预加载依赖或模拟初始数据。

### 在 Dart 中调用

```dart
import 'package:opentool_dart/opentool_client.dart';

Future<void> main() async {
  final client = OpenToolClient(
    toolHost: HostType.LOCALHOST,
    toolPort: 17002,
    toolApiKey: 'your-key',
  );

  final version = await client.version();
  print(version.toJson());

  final unary = await client.call(FunctionCall(id: 'call-0', name: 'count', arguments: {}));
  print(unary.toJson());

  await client.streamCall(
    FunctionCall(id: 'call-1', name: 'sequentiallyRead', arguments: {}),
    (event, toolReturn) => print('$event ${toolReturn.result}'),
  );

  final openTool = await client.load();
  print(openTool?.toJson());

  await client.stop();
}
```

## CLI 与 HTTP 参考

- 默认前缀 `/opentool`，包含 `GET /version`、`POST /call`、`POST /streamCall`、`GET /load`、`POST /stop`。
- 内置 CLI 参数：`--opentoolServerTag`、`--opentoolServerHost`、`--opentoolServerPort`、可重复的 `--opentoolServerApiKeys`，亦可扩展自定义参数。
- 流式返回采用 Server-Sent Events，事件顺序为 `start` → 多次 `data`/`error` → 流关闭即 `done`。

## JSON 规范加载器

- 仅需 Schema 能力时可直接导入 `package:opentool_dart/opentool_schema.dart`。
- 规范文件建议放在 `json/` 或 `example/json-example`。`OpenToolJsonLoader().loadFromFile(path)` 会解析 `$ref` 并生成完整 `OpenTool` 对象，远程内容可用 `load(jsonString)`。
- 字段含义请参考 [OpenTool 规范](https://github.com/opentool-hub/opentool-spec)。

## 示例与开发流程

- `example/server` 与 `example/client` 提供可运行示例，对应命令：`dart run example/server/main.dart`、`dart run example/client/main.dart`。
- 独立 Schema fixture 位于 `example/json-example` 与根目录 `json/`。
- 常用指令：`dart pub get`、`dart analyze`、`dart format lib example json`、`dart test`。
- 新增 CLI 参数、HTTP 接口或 Schema 字段时请同步更新 README，保持各 SDK 行为一致。
