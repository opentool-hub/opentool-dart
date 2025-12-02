import 'package:opentool_dart/opentool_server.dart';
import 'dart:io' as io;
import 'mock_util.dart';

class MockTool extends CliTool {
  MockUtil mockUtil = MockUtil();

  @override
  Future<Map<String, dynamic>?> initArgs(Map<String, dynamic>? cliArgs) async {
    List<String>? newValues = cliArgs?["newValues"] as List<String>?;
    if(newValues != null && newValues.isNotEmpty) {
      newValues.forEach((value) => mockUtil.create(value));
    }
    return cliArgs;
  }
  
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
  Future<void> streamCall(String name, Map<String, dynamic>? arguments, void Function(String event, Map<String, dynamic> data) sendEvent) async {
    if(name == "sequentiallyRead") {
      mockUtil.sequentiallyRead((String data) {
        sendEvent(EventType.DATA, {"data": data});
      });
      sendEvent(EventType.DONE, {});  /// REQUIRED: send DONE event to close the stream.
    } else {
      sendEvent(EventType.ERROR, FunctionNotSupportedException(functionName: name).toJson());
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