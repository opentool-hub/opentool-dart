import '../../opentool_dart.dart';

abstract class ToolDriver {
  List<FunctionModel> parse();
  bool hasFunction(String functionName);
  Future<ToolReturn> call(FunctionCall functionCall);
}