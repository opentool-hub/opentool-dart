import 'dart:async';
import '../model/opentool.dart';

abstract class Tool {
  Future<Map<String, dynamic>?> init(Map<String, dynamic>? cliArgs) async => cliArgs;
  Future<Map<String, dynamic>> call(String name, Map<String, dynamic>? arguments);
  Future<void> streamCall(String name, Map<String, dynamic>? arguments, void Function(String event, Map<String, dynamic> data) onEvent) async => null;
  Future<OpenTool?> load() async => null;
  Future<void> dispose() async => null;
}