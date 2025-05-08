import 'dart:io';
import 'package:opentool_dart/opentool_dart.dart';
import 'package:opendyn_dart/opendyn_dart.dart' as od;

Future<void> main() async {
  String jsonFileName = "example.json";
  String jsonPath = "${Directory.current.path}${Platform.pathSeparator}example${Platform.pathSeparator}json${Platform.pathSeparator}opendyn${Platform.pathSeparator}$jsonFileName";
  
  od.OpenDynLoader openDynLoader = od.OpenDynLoader();
  od.OpenDyn openDyn = await openDynLoader.loadFromFile(jsonPath);
  
  String dynFileName = "libexample.dll"; // Windows
  if(Platform.isMacOS) {
    var result = await Process.run('uname', ['-m']);
    if (result.stdout.toString().trim() == 'arm64') {
      dynFileName = "libexample_arm64.dylib"; // macOS ARM
    } else {
      dynFileName = "libexample_x86_64.dylib"; // macOS Intel
    }
  } else if(Platform.isLinux) {
    dynFileName = "libexample.so"; // Linux
  }
  File dynFile = File("${Directory.current.path}${Platform.pathSeparator}example${Platform.pathSeparator}dyns${Platform.pathSeparator}$dynFileName");
  OpenDynDriver openDynDriver = OpenDynDriver(openDyn: openDyn, dynFile: dynFile);

  // Map<String, dynamic> params = {
  //   "a": 1,
  //   "b": 2
  // };
  // FunctionCall functionCall = FunctionCall(
  //   id: "callId-0", 
  //   name: "add",
  //   parameters: params
  // );

  // Map<String, dynamic> params = {
  //   "a": 1.1,
  //   "b": 2.2,
  // };
  // FunctionCall functionCall = FunctionCall(
  //   id: "callId-1", 
  //   name: "multiply",
  //   parameters: params
  // );

  Map<String, dynamic> args = {
    "a": 10,
    "b": 20
  };
  FunctionCall functionCall = FunctionCall(
    id: "callId-2",
    name: "swap_and_sum",
    arguments: args
  );
  
  try {
    ToolReturn toolReturn = await openDynDriver.call(functionCall);
    print(toolReturn.toJson());
  } catch (e) {
    print("Error: $e");
  } finally {
    await openDynDriver.dispose();
  }
}