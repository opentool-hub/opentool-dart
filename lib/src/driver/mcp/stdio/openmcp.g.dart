// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openmcp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenMCP _$OpenMCPFromJson(Map<String, dynamic> json) => OpenMCP(
      mcpServer: MCPServer.fromJson(json['mcpServer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenMCPToJson(OpenMCP instance) => <String, dynamic>{
      'mcpServer': instance.mcpServer,
    };

MCPServer _$MCPServerFromJson(Map<String, dynamic> json) => MCPServer(
      command: json['command'] as String,
      args: (json['args'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MCPServerToJson(MCPServer instance) => <String, dynamic>{
      'command': instance.command,
      'args': instance.args,
    };
