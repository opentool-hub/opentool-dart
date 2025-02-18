import 'model.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;

Future<Map<String, dynamic>> runDynFunction(FunctionInfo functionInfo) async {
  try {
    final executablePath = await _getDynBridgeExecutablePath();

    final dynfilePath = functionInfo.dynFile.path;
    final funcName = functionInfo.name;
    final params = jsonEncode([
      for (var param in functionInfo.parameterInfoList)
        {
          'name': param.name,
          'data_type': param.cDataType,
          'is_pointer': param.isPointer,
          'is_in': param.isIn,
          'value': param.value
        }
    ]);

    final returnType = jsonEncode({
      'data_type': "int",
      'is_pointer': false,
    });

    final process = await Process.start(executablePath, [
      '--lib_path=$dynfilePath',
      '--func_name=$funcName',
      '--params=$params',
      '--return_type=$returnType',
    ]);

    final output = await process.stdout.transform(utf8.decoder).join();
    final error = await process.stderr.transform(utf8.decoder).join();
    final exitCode = await process.exitCode;
    
    if (exitCode != 0) {
      throw Exception('Call dynamic library bridge failed: $error');
    }
  
    return jsonDecode(output);
  } catch (e) {
    throw Exception('Call dynamic library function failed: $e');
  }
}

Future<String> _getDynBridgeExecutablePath() async {
  String executableName;
  
  if (Platform.isWindows) {
    executableName = 'dyn_bridge.exe';
  } else if (Platform.isMacOS) {
    var result = await Process.run('uname', ['-m']);
    if (result.stdout.toString().trim() == 'arm64') {
      executableName = 'dyn_bridge_arm64'; // macOS ARM
    } else {
      executableName = 'dyn_bridge_x86_64'; // macOS Intel
    }
  } else {
    executableName = 'dyn_bridge'; // Linux
  }
  
  final projectDir = Directory.current.path;
  final executablePath = path.join(projectDir, "libs", "dyn_bridge", Platform.operatingSystem.toLowerCase(), executableName);

  if (!Platform.isWindows) {
    await Process.run('chmod', ['+x', executablePath]);
  }

  return executablePath;
}