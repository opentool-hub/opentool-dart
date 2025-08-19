import '../model/opentool.dart';

abstract class Tool {
  Future<Map<String, dynamic>> call(String name, Map<String, dynamic>? arguments);
  Future<OpenTool?> load() async => null;
}