import '../model/function_model.dart';
import 'model.dart';

abstract class ToolDriver {
  Future<void> init() async {}
  List<FunctionModel> parse();
  bool hasFunction(String functionName);
  Future<ToolReturn> call(FunctionCall functionCall);
  Future<void> dispose() async {}
}