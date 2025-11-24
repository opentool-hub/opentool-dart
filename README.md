# OpenTool SDK for Dart

English | [中文](README-zh_CN.md)

OpenTool SDK for Dart ships the building blocks required to host or consume OpenTool-compatible agents: a Shelf-based HTTP/JSON-RPC server, an HTTP client with unary + SSE calls, and a JSON schema loader. Everything is pure Dart so you can embed the tool runtime anywhere the Dart VM runs.

## Library Entrypoints

- `package:opentool_dart/opentool_server.dart` — server runtime, CLI helpers, and Tool base class.
- `package:opentool_dart/opentool_client.dart` — HTTP/JSON-RPC client plus DTO/LLM models.
- `package:opentool_dart/opentool_schema.dart` — JSON specification models and loader.

## Features

- `OpenToolServer` mounts `/opentool` JSON-RPC endpoints backed by your `Tool` implementation and optional API-key auth.
- `OpenToolClient` covers versions, unary `call`, SSE `streamCall`, metadata `load`, and remote `stop`.
- `OpenToolJsonLoader` parses OpenTool JSON specs (see `json/` or `example/json-example`) and resolves `$ref` schemas.
- Example apps in `example/server` and `example/client` demonstrate CRUD flows, streaming reads, and CLI overrides via `CliArguments`.

## Requirements

- Dart SDK `>=3.8.0 <4.0.0`
- Optional: API keys for Bearer auth if you enable `--opentoolServerApiKeys`.

## Installation

Add the package to your project:

```sh
dart pub add opentool_dart
```

Or update `pubspec.yaml` manually:

```yaml
dependencies:
  opentool_dart: ^2.0.0
```

Run `dart pub get` afterwards.

## Quick Start

### Implement a Tool

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

### Launch the server

```sh
dart run example/server/main.dart \
  --opentoolServerTag 1.0.0 \
  --opentoolServerHost 0.0.0.0 \
  --opentoolServerPort 17002 \
  --opentoolServerApiKeys your-key \
  --newValues Foo \
  --newValues Bar
```

`CliArguments` feeds these switches into `Tool.init`, so you can hydrate dependencies or load fixtures before handlers accept requests.

### Call the tool from Dart

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

## CLI and HTTP Reference

- Base path defaults to `/opentool`. Endpoints: `GET /version`, `POST /call`, `POST /streamCall`, `GET /load`, `POST /stop`.
- CLI flags: `--opentoolServerTag`, `--opentoolServerHost`, `--opentoolServerPort`, and repeatable `--opentoolServerApiKeys` for Bearer validation. Add your own switches for tool-specific config.
- Streaming responses use Server-Sent Events: events `start`, `data`, `error`, and an implicit `done` when the stream closes.

## JSON Specification Loader

- Import `package:opentool_dart/opentool_schema.dart` when you only need the spec models.
- Store OpenTool specs under `json/` or `example/json-example`. `OpenToolJsonLoader().loadFromFile(path)` builds the `OpenTool` tree and resolves `$ref` schemas; use `load(jsonString)` for remote inputs.
- Refer to the [OpenTool specification](https://github.com/opentool-hub/opentool-spec) for field semantics.

## Examples & Development

- Sample server/client pairs live in `example/server` and `example/client`; run them with `dart run example/server/main.dart` and `dart run example/client/main.dart`.
- Standalone schema fixtures are under `example/json-example` and `json/`.
- Developer workflow: `dart pub get`, `dart analyze`, `dart format lib example json`, and `dart test`.
- Document any new CLI flags, HTTP endpoints, or schema fields here to keep downstream SDKs aligned.
