# OpenTool SDK for Dart

English | [中文](README-zh_CN.md)

OpenTool SDK for Dart provides a lightweight Shelf server, an HTTP/JSON-RPC client, and a JSON specification loader so that OpenTool-compatible agents can be hosted and consumed from pure Dart code.

## Features

- `OpenToolServer` exposes `/opentool` JSON-RPC endpoints backed by your own `Tool` implementation.
- `OpenToolClient` wraps version checks, unary calls, streaming calls (Server-Sent Events), metadata discovery, and shutdown.
- `OpenToolJsonLoader` parses OpenTool JSON specs (for example, the files in `json/`) and wires `$ref` schemas into strongly typed Dart objects.
- Example apps in `example/server` and `example/client` showcase a full CRUD tool plus streaming output.

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

### Run the server

```sh
dart run example/server/main.dart \
  --opentoolServerTag 1.0.0 \
  --opentoolServerHost 0.0.0.0 \
  --opentoolServerPort 17001 \
  --opentoolServerApiKeys your-key
```

You can add custom CLI switches via `CliArguments.addCustomOption` / `addCustomMultiOption` for domain-specific configuration before the Tool initializes.

### Call the tool from Dart

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

## CLI and HTTP Reference

- Base path defaults to `/opentool`. Endpoints: `GET /version`, `POST /call`, `POST /streamCall`, `GET /load`, `POST /stop`.
- CLI flags: `--opentoolServerTag`, `--opentoolServerHost`, `--opentoolServerPort`, and repeatable `--opentoolServerApiKeys` for Bearer validation. Add your own switches for tool-specific config.
- Streaming responses use Server-Sent Events: events `start`, `data`, `error`, and an implicit `done` when the stream closes.

## JSON Specification Loader

- Store OpenTool specs under `json/` (see `database-example.json` and `weather-example.json`).
- Use `OpenToolJsonLoader().loadFromFile(path)` to populate `OpenTool` + schema graph, or call `load(jsonString)` when fetching from a remote registry.
- Refer to the [OpenTool specification](https://github.com/opentool-hub/opentool-spec) for schema structure and `$ref` semantics.

## Development & Testing

- Install deps: `dart pub get`.
- Lint and format: `dart analyze` and `dart format lib example json`.
- Add tests under `test/` mirroring the `lib/` structure and run them with `dart test`.
- When contributing, please document new CLI flags and endpoints in `README.md` so others stay in sync.
