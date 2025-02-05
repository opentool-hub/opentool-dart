import 'package:opentool_dart/opentool_dart.dart';

Future<void> main() async {

  Map<String, dynamic> createParams = {};
  FunctionCall functionCall = FunctionCall(id: "callId-0", name: "getAvailablePorts", parameters: createParams);

  ToolDriver serialPortDriver = SerialPortDriver();

  ToolReturn toolReturn = await serialPortDriver.call(functionCall);
  print(toolReturn.toJson());
}