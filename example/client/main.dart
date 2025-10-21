import 'package:opentool_dart/opentool_dart.dart';
import '../server/main.dart';

Future<void> main() async {
  Client client = OpenToolClient(toolHost: HostType.LOCALHOST, toolPort: TOOL_PORT, toolApiKey: TOOL_API_KEYS[0]);

  // Check Version
  Version version = await client.version();
  print(version.toJson());

  // Call Tool
  Map<String, dynamic> arguments = {};
  FunctionCall functionCall = FunctionCall(id: "callId-0", name: "count", arguments: arguments);
  ToolReturn toolReturn = await client.call(functionCall);
  print(toolReturn.toJson());

  // StreamCall Tool
  Map<String, dynamic> arguments1 = {};
  FunctionCall functionCall1 = FunctionCall(id: "callId-1", name: "sequentiallyRead", arguments: arguments1);
  await client.streamCall(functionCall1, (event, toolReturn) {
    print(toolReturn.toJson());
  });

  // Load OpenTool
  OpenTool? openTool = await client.load();
  print(openTool?.toJson());

  // Stop OpenTool
  StatusInfo? statusInfo = await client.stop();
  print(statusInfo?.toJson());
}