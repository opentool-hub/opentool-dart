import 'dart:convert';
import 'dart:io';
import 'package:mcp_dart/mcp_dart.dart';
import '../../../model/function_model.dart';
import '../../../model/parameter.dart';
import '../../../model/schema.dart';
import '../../model.dart';
import '../../tool_driver.dart';
import 'openmcp.dart';

class McpStdioDriver extends ToolDriver {
  late Client client;
  late StdioClientTransport transport;
  late List<FunctionModel> functionModelList;

  McpStdioDriver(OpenMCP openMcp, {void Function()? onTransportClose}) {
    StdioServerParameters serverParams = StdioServerParameters(
      command: openMcp.mcpServer.command,
      args: openMcp.mcpServer.args,
      stderrMode: ProcessStartMode.normal,
    );
    transport = StdioClientTransport(serverParams);

    Implementation clientInfo = Implementation(name: 'McpStdioDriver', version: '1.0.0');

    client = Client(clientInfo);

    transport.onerror = (error) {
      throw error;
    };

    transport.onclose = () {
      if(onTransportClose != null) onTransportClose();
    };
  }

  factory McpStdioDriver.fromOpenMCPString(String openMCPString) {
    OpenMCP openMcp = OpenMCP.fromJson(jsonDecode(openMCPString));
    return McpStdioDriver(openMcp);
  }

  @override
  Future<void> init() async {
    await client.connect(transport);
    ListToolsResult listToolsResult = await client.listTools();
    functionModelList = _convertToFunctionModelList(listToolsResult);
  }

  @override
  Future<ToolReturn> call(FunctionCall functionCall) async {
    CallToolResult callToolResult = await client.callTool(CallToolRequestParams(name: functionCall.name, arguments: functionCall.parameters));
    return ToolReturn(id: functionCall.id, result: callToolResult.toJson());
  }

  @override
  bool hasFunction(String functionName) {
    return functionModelList.any((functionModel) => functionModel.name == functionModel);
  }

  @override
  List<FunctionModel> parse() {
    return functionModelList;
  }

  List<FunctionModel> _convertToFunctionModelList(ListToolsResult listToolsResult) {
    return listToolsResult.tools.map((Tool tool){
      return FunctionModel(
          name: tool.name,
          description: tool.description??"",
          parameters: _convertToolInputSchemaToParameters(tool.inputSchema)
      );
    }).toList();
  }

  List<Parameter> _convertToolInputSchemaToParameters(ToolInputSchema schema) {
    if (schema.properties == null) {
      return [];
    }

    List<String> requiredProperties = [];
    if (schema.additionalProperties.containsKey('required')) {
      requiredProperties = List<String>.from(schema.additionalProperties['required']);
    }

    return schema.properties!.entries.map((entry) {
      String paramName = entry.key;
      Map<String, dynamic> paramSchema = entry.value as Map<String, dynamic>;

      String? description = paramSchema['description'] as String?;

      String type = paramSchema['type'] as String;

      List<String>? enumValues = paramSchema.containsKey('enum') ? List<String>.from(paramSchema['enum']) : null;

      Schema? items;
      if (type == 'array' && paramSchema.containsKey('items')) {
        items = parseSchema(paramSchema['items'] as Map<String, dynamic>);
      }

      Map<String, Schema>? properties;
      List<String>? required;
      if (type == 'object') {
        properties = paramSchema.containsKey('properties') ? (paramSchema['properties'] as Map<String, dynamic>).map((key, value) => MapEntry(key, parseSchema(value as Map<String, dynamic>))) : null;
        required = paramSchema.containsKey('required') ? List<String>.from(paramSchema['required']) : null;
      }
      Schema schema = Schema(type: type, description: description, properties: properties, items: items, enum_: enumValues, required: required,);
      bool isRequired = requiredProperties.contains(paramName);
      return Parameter(name: paramName, description: description, schema: schema, required: isRequired,);
    }).toList();
  }

  Schema parseSchema(Map<String, dynamic> schemaMap) {
    String type = schemaMap['type'] as String;
    String? description = schemaMap['description'] as String?;
    List<String>? enumValues = schemaMap.containsKey('enum') ? List<String>.from(schemaMap['enum']) : null;

    Schema? items;
    if (type == 'array' && schemaMap.containsKey('items')) {
      items = parseSchema(schemaMap['items'] as Map<String, dynamic>);
    }

    Map<String, Schema>? properties;
    List<String>? required;
    if (type == 'object') {
      properties = schemaMap.containsKey('properties') ? (schemaMap['properties'] as Map<String, dynamic>).map((key, value) => MapEntry(key, parseSchema(value as Map<String, dynamic>))) : null;
      required = schemaMap.containsKey('required') ? List<String>.from(schemaMap['required']) : null;
    }

    return Schema(type: type, description: description, properties: properties, items: items, enum_: enumValues, required: required,);
  }
}