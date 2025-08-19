import 'package:opentool_dart/opentool_dart.dart';

Future<void> main() async {
  Client client = OpenToolClient(apiKey: "bb31b6a6-1fda-4214-8cd6-b1403842070c");

  // Check Version
  Version version = await client.version();
  print(version.toJson());

  // Call Tool
  Map<String, dynamic> arguments = {};
  FunctionCall functionCall = FunctionCall(id: "callId-0", name: "count", arguments: arguments);
  ToolReturn toolReturn = await client.call(functionCall);
  print(toolReturn.toJson());

  // Load OpenTool
  OpenTool? openTool = await client.load();
  print(openTool?.toJson());
}