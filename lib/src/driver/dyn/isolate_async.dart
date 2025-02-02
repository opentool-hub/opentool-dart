import 'dart:async';
import 'dart:isolate';

import '../model.dart';
import 'model.dart';
import 'open_dyn_isolate.dart';

class IsolateAsync {
  OpenDynIsolate openDynIsolate = OpenDynIsolate();

  bool hasInit = false;
  final ReceivePort _mainReceivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _subSendPort;
  final Map<String, Completer<ToolReturn>> _idCompleterMap = {};

  Future<void> init() async {
    Completer<SendPort> completer = Completer<SendPort>();
    _isolate = await Isolate.spawn(OpenDynIsolate.isolateEntry, _mainReceivePort.sendPort);

    _mainReceivePort.listen((dynamic message) {
      if (message is SendPort) {
        hasInit = true;
        completer.complete(message);
      } else if(message is ToolReturn) {
        ToolReturn toolReturn = message;
        if (_idCompleterMap.containsKey(toolReturn.id)) {
          Completer completer = _idCompleterMap[toolReturn.id]!;
          completer.complete(toolReturn);
          _idCompleterMap.remove(toolReturn.id);
        }
      }
    });

    _subSendPort = await completer.future;
  }

  Future<ToolReturn> sendMessage(FunctionInfoWithId functionInfoWithId) async {
    Completer<ToolReturn> completer = Completer<ToolReturn>();
    _idCompleterMap[functionInfoWithId.id] = completer;

    _subSendPort.send(functionInfoWithId);
    return completer.future;
  }

  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    _mainReceivePort.close();
  }
}