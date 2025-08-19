# OpenTool SDK for Dart

[English](README.md) | 中文

OpenTool的client和server的Dart SDK，并连带OpenTool JSON的Parser

## Example

1. 运行 `/example/server/main.dart` 启动一个OpenTool Server
2. 运行 `/example/client/main.dart` 启动OpenTool Client

## 安装

在Dart项目的依赖文件中增加：

```yaml
dependencies:
    opentool_dart: ^1.1.0
```

## 使用

1. 实现`Tool`接口
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
2. 拉起`Server`
    ```dart
    Future<void> main() async {
      Tool tool = MockTool();
      Server server = OpenToolServer(tool, "1.0.0",apiKeys: ["6621c8a3-2110-4e6a-9d62-70ccd467e789", "bb31b6a6-1fda-4214-8cd6-b1403842070c"]);
      await server.start();
    }
    ```


## 说明

1. 默认端口`9627`，Client与Server支持更换端口，注意对应上即可
2. 新的Tool需要实现`call`方法，可选实现`load`方法，建议采用[OpenTool规范的JSON格式文件](https://github.com/opentool-hub/opentool-spec)来描述Tool，但同样支持采用代码方式构建OpenTool对象。