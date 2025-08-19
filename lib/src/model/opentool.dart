import 'package:json_annotation/json_annotation.dart';
import 'function_model.dart';
import 'info.dart';
import 'server.dart';
import 'schema.dart';

part 'opentool.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenTool {
  String opentool;
  Info info;
  Server? server;
  List<FunctionModel> functions;
  Map<String, Schema>? schemas;

  OpenTool({required this.opentool, required this.info, this.server, required this.functions, this.schemas});

  factory OpenTool.fromJson(Map<String, dynamic> json) => _$OpenToolFromJson(json);

  Map<String, dynamic> toJson() => _$OpenToolToJson(this);
}