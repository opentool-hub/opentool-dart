import '../../opentool_dart.dart';

abstract class OpenToolDriver extends ToolDriver {
  late OpenTool openTool;

  OpenToolDriver bind(OpenTool openTool) {
    this.openTool = openTool;
    return this;
  }

  OpenTool getOpenTool() => openTool;

  @override
  List<FunctionModel> parse() {
    return openTool.functions;
  }

  @override
  bool hasFunction(String functionName) => openTool.functions
      .where((FunctionModel functionModel) => functionModel.name == functionName)
      .isNotEmpty;
}