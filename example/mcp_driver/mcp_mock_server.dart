import 'package:mcp_dart/mcp_dart.dart';

import 'mock_util.dart';

void main() async {
  MockUtil mockUtil = MockUtil();

  final server = McpServer(
    Implementation(name: 'Mock CRUD Server', version: '1.0.0'),
    options: ServerOptions(
      capabilities: ServerCapabilities(
        tools: ServerCapabilitiesTools(),
      ),
    ),
  );

  server.tool(
    'count',
    description: 'Get storage size.',
    inputSchemaProperties: {},
    callback: ({args, extra}) async {
      int count = mockUtil.count();
      return CallToolResult(
        content: [TextContent(text: 'count: $count')],
      );
    },
  );

  server.tool(
    'create',
    description: 'Create a text in storage',
    inputSchemaProperties: {
      'text': {'type': 'string'},
    },
    callback: ({args, extra}) async {
      String text = args!['text'] as String;
      int id = mockUtil.create(text);
      return CallToolResult(
        content: [TextContent(text: 'id: $id')],
      );
    },
  );

  server.tool(
    'read',
    description: 'Read text from storage by id',
    callback: ({args, extra}) async {
      int id = args!["id"] as int;
      String text = mockUtil.read(id);
      return CallToolResult(
        content: [TextContent(text: 'text: $text')],
      );
    },
  );

  server.tool(
    'update',
    description: 'Update a text in storage by id',
    inputSchemaProperties: {
      'id': {'type': 'integer'},
      'text': {'type': 'string'}
    },
    callback: ({args, extra}) async {
      int id = args!['id'] as int;
      String text = args['text'] as String;
      mockUtil.update(id, text);
      return CallToolResult(
        content: [TextContent(text: '{"result": "Update successfully."}')],
      );
    },
  );

  server.tool(
    'delete',
    description: 'Delete a text in storage',
    inputSchemaProperties: {
      'id': {'type': 'integer'},
    },
    callback: ({args, extra}) async {
      int id = args!['id'] as int;
      mockUtil.delete(id);
      return CallToolResult(
        content: [TextContent(text: '{"result": "Delete successfully."}')],
      );
    },
  );

  server.connect(StdioServerTransport());
}
