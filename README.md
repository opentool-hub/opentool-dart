# OpenTool SDK for Dart

English | [中文](README-zh_CN.md)

Dart SDK for OpenTool client and server, including OpenTool JSON parser.

## Example

1. Run `/example/server/main.dart` to start an OpenTool Server
2. Run `/example/client/main.dart` to start an OpenTool Client

## Installation

Add the following to your Dart project dependencies:

```yaml
dependencies:
    opentool_dart: ^1.1.0
```

## Usage

1. Implement the `Tool` interface:

   ```dart
   class MockTool extends Tool {
     MockUtil mockUtil = MockUtil();

     @override
     Future<Map<String, dynamic>> call(String name, Map<String, dynamic>? arguments) async {
       if(name == "count") {
         int count = mockUtil.count();
         return {"count": count};
       } else {
         return FunctionNotSupportedException(functionName: name).toJson();
       }
     }

     @override
     Future<OpenTool?> load() async {
       String folder = "${io.Directory.current.path}${io.Platform.pathSeparator}example${io.Platform.pathSeparator}server";
       String fileName = "mock_tool.json";
       String jsonPath = "$folder${io.Platform.pathSeparator}$fileName";
       OpenTool openTool = await OpenToolJsonLoader().loadFromFile(jsonPath);
       return openTool;
     }
   }
   ```

2. Start the `Server`:

   ```dart
   Future<void> main() async {
     Tool tool = MockTool();
     Server server = OpenToolServer(tool, "1.0.0", apiKeys: ["6621c8a3-2110-4e6a-9d62-70ccd467e789", "bb31b6a6-1fda-4214-8cd6-b1403842070c"]);
     await server.start();
   }
   ```

## Notes

1. The default port is `9627`. Both Client and Server can change the port, just make sure they match.
2. New tools must implement the `call` method. The `load` method is optional, but it's recommended to use the [OpenTool JSON specification](https://github.com/opentool-hub/opentool-spec) to describe tools. Programmatic creation of the `OpenTool` object is also supported.
