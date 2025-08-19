import 'package:opentool_dart/opentool_dart.dart';
import 'dart:io' as io;
import 'mock_util.dart';

class MockTool extends Tool {
  MockUtil mockUtil = MockUtil();
  
  @override
  Future<Map<String, dynamic>> call(String name, Map<String, dynamic>? arguments) async {
    if(name == "count") {
      int count = mockUtil.count();
      return {"count": count};
    } else if(name == "create" && arguments != null) {
      String text = arguments["text"] as String;
      int id = mockUtil.create(text);
      return {"id": id};
    } else if(name == "read" && arguments != null) {
      int id = arguments["id"] as int;
      String text = mockUtil.read(id);
      return {"text": text};
    } else if(name == "update" && arguments != null) {
      int id = arguments["id"] as int;
      String text = arguments["text"] as String;
      mockUtil.update(id, text);
      return {"result": "Update successfully."};
    } else if(name == "delete" && arguments != null) {
      int id = arguments["id"] as int;
      mockUtil.delete(id);
      return {"result": "Delete successfully."};
    } else if(name == "run") {
      try {
        mockUtil.run();
      } catch(e) {
        /// Simulate to throw a fatal error.
        throw ToolBreakException(e.toString());
      }
      return {"result": "Delete successfully."};
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