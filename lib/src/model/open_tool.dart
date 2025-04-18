import 'package:json_annotation/json_annotation.dart';
import 'function_model.dart';
import 'info.dart';
import 'schema.dart';

part 'open_tool.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenTool {
  String opentool;
  Info info;
  List<FunctionModel> functions;
  Map<String, Schema>? schemas;

  OpenTool({required this.opentool, required this.info, required this.functions});

  factory OpenTool.fromJson(Map<String, dynamic> json) => _$OpenToolFromJson(json);

  Map<String, dynamic> toJson() => _$OpenToolToJson(this);
}