import 'package:opentool_dart/opentool_dart.dart';
import 'mock_tool.dart';

int TOOL_PORT = 9627;
List<String> TOOL_API_KEYS = ["6621c8a3-2110-4e6a-9d62-70ccd467e789", "bb31b6a6-1fda-4214-8cd6-b1403842070c"];

Future<void> main() async {
  Tool tool = MockTool();
  Server server = OpenToolServer(tool, "1.0.0",toolHost: HostType.ANY, toolPort: TOOL_PORT, toolApiKeys: TOOL_API_KEYS);
  await server.start();
}