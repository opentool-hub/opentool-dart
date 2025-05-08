import 'dart:io';
import 'package:opentool_dart/opentool_dart.dart';

Future<void> main() async {
  String mcpFileName = "example.json";
  File file = File("${Directory.current.path}${Platform.pathSeparator}example${Platform.pathSeparator}mcp_driver${Platform.pathSeparator}$mcpFileName");
  String jsonString = await file.readAsString();
  McpStdioDriver mcpStdioDriver = McpStdioDriver.fromOpenMCPString(jsonString);
  await mcpStdioDriver.init();

  Map<String, dynamic> args = {
    "text": "test"
  };
  FunctionCall functionCall = FunctionCall(
    id: "callId-2",
    name: "create",
    arguments: args
  );

  try {
    ToolReturn toolReturn = await mcpStdioDriver.call(functionCall);
    print("toolReturn: ${toolReturn.toJson()}");
  } catch (e) {
    print("Error: $e");
  }
}