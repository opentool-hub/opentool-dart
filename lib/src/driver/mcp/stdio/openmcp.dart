import 'package:json_annotation/json_annotation.dart';
part 'openmcp.g.dart';

@JsonSerializable()
class OpenMCP {
  MCPServer mcpServer;
  OpenMCP({required this.mcpServer});

  factory OpenMCP.fromJson(Map<String, dynamic> json) => _$OpenMCPFromJson(json);
  Map<String, dynamic> toJson() => _$OpenMCPToJson(this);
}

@JsonSerializable()
class MCPServer {
  String command;
  List<String> args;

  MCPServer({required this.command, required this.args});

  factory MCPServer.fromJson(Map<String, dynamic> json) => _$MCPServerFromJson(json);
  Map<String, dynamic> toJson() => _$MCPServerToJson(this);
}