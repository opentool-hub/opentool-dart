import '../tool/tool.dart';

abstract class CliTool extends Tool {
  Future<Map<String, dynamic>?> initArgs(Map<String, dynamic>? args) async => args;
}