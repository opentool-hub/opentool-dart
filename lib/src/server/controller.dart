import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../tool/exception.dart';
import '../tool/tool.dart';
import '../dto.dart';

const Map<String, String> jsonHeaders = {'Content-Type': 'application/json'};

class Controller {
  final Tool tool;
  final String version;

  Controller(this.tool, this.version);

  /// GET /version
  Future<Response> getVersion(Request request) async {
    final versionObj = Version(version: version);
    return Response.ok(
      jsonEncode(versionObj.toJson()),
      headers: jsonHeaders,
    );
  }

  /// POST /call
  Future<Response> call(Request request) async {
    try {
      final contentType = request.headers['Content-Type'] ?? '';
      if (!contentType.contains('application/json')) {
        return Response(
          400,
          body: jsonEncode({
            'error': 'Content-Type must be application/json',
          }),
          headers: jsonHeaders,
        );
      }

      final payload = await request.readAsString();
      final data = jsonDecode(payload);
      final body = JsonRPCHttpRequestBody.fromJson(data);

      final result = await tool.call(body.method, body.params);
      final responseBody = JsonRPCHttpResponseBody(
        result: result,
        id: body.id,
      );

      return Response.ok(
        jsonEncode(responseBody.toJson()),
        headers: jsonHeaders,
      );
    } catch (e) {
      final error = JsonRPCHttpResponseBodyError(
        code: 500,
        message: e.toString(),
      );
      final responseBody = JsonRPCHttpResponseBody(
        result: {},
        id: '',
        error: error,
      );
      return Response.ok(
        jsonEncode(responseBody.toJson()),
        headers: jsonHeaders,
      );
    }
  }

  /// GET /load
  Future<Response> load(Request request) async {
    try {
      final openTool = await tool.load();
      final responseBody = openTool?.toJson() ?? JsonParserException().toJson();
      return Response.ok(
        jsonEncode(responseBody),
        headers: jsonHeaders,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: jsonHeaders,
      );
    }
  }
}