import 'package:opentool_dart/opentool_dart.dart';
import 'mock_tool.dart';

int TOOL_PORT = 17002;
List<String> TOOL_API_KEYS = ["6621c8a3-2110-4e6a-9d62-70ccd467e789", "bb31b6a6-1fda-4214-8cd6-b1403842070c"];

Future<void> main() async {
  List<String> simulateCliArgs = [
    "--newValues", "Foo",
    "--newValues", "bar",
    "--$CLI_ARGUMENT_TAG", "1.0.0",
    "--$CLI_ARGUMENT_HOST", "0.0.0.0",
    "--$CLI_ARGUMENT_PORT", "$TOOL_PORT",
    "--$CLI_ARGUMENT_APIKEYS", TOOL_API_KEYS[0],
    "--$CLI_ARGUMENT_APIKEYS", TOOL_API_KEYS[1]
  ];

  CliArguments cliArguments = CliArguments(simulateCliArgs)
    .addCustomMultiOption('newValues', help: 'Demo to customize args, will add new values. e.g. --newValues Foo --newValues Bar');

  Tool tool = MockTool();
  Server server = OpenToolServer(tool: tool, cliArguments: cliArguments);
  await server.start();
}