import 'dart:isolate';

import 'package:opentool_dart/opentool_dart.dart';

import 'dyn_util.dart';
import 'model.dart';

class OpenDynIsolate {
  static final ReceivePort _subReceivePort = ReceivePort();
  static late SendPort _mainSendPort;

  static Future<ToolReturn> call(FunctionInfoWithId functionInfoWithId) async {

    Map<String, dynamic> result = await runDynFunction(functionInfoWithId.functionInfo);
    return ToolReturn(id: functionInfoWithId.id, result: result);
  }

  static void isolateEntry(SendPort mainSendPort) {
    _mainSendPort = mainSendPort;
    _mainSendPort.send(_subReceivePort.sendPort);
    _subReceivePort.listen((dynamic message) {
      if (message is FunctionInfoWithId) {
        call(message).then((ToolReturn toolReturn) {
          _mainSendPort.send(toolReturn);
        });
      }
    });
  }
}
