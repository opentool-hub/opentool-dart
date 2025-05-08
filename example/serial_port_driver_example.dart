import 'package:opentool_dart/opentool_dart.dart';

Future<void> main() async {

  Map<String, dynamic> args = {};
  FunctionCall functionCall = FunctionCall(id: "callId-0", name: "getAvailablePorts", arguments: args);

  ToolDriver serialPortDriver = SerialPortDriver();

  ToolReturn toolReturn = await serialPortDriver.call(functionCall);
  print(toolReturn.toJson());
}