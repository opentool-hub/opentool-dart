import 'dart:async';
import '../model/opentool.dart';

abstract class Tool {
  Future<void> init() async => null;
  Future<Map<String, dynamic>> call(
    String name,
    Map<String, dynamic>? arguments,
  );
  Future<void> streamCall(
    String name,
    Map<String, dynamic>? arguments,
    void Function(String event, Map<String, dynamic> data) onEvent,
  ) async => null;
  Future<OpenTool?> load() async => null;
  Future<void> dispose() async => null;
}
