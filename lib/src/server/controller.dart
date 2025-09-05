import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import '../tool/exception.dart';
import '../tool/model.dart';
import '../tool/tool.dart';
import '../dto.dart';

class Controller {
  final Tool tool;
  final String version;
  Future<void> Function() onStop;
  String? serverId;
  final Map<String, String> jsonHeaders = {HttpHeaders.contentTypeHeader: 'application/json', HttpHeaders.cacheControlHeader: 'no-cache', HttpHeaders.connectionHeader: 'keep-alive',};
  final Map<String, String> streamHeaders = {HttpHeaders.contentTypeHeader: 'text/event-stream', HttpHeaders.cacheControlHeader: 'no-cache', HttpHeaders.connectionHeader: 'keep-alive', 'Cache-Control': 'no-store',};

  Controller(this.tool, this.version, this.onStop);

  void setServerId(String serverId) {
    this.serverId = serverId;
  }

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

  /// POST /streamCall
  Future<Response> streamCall(Request request) async {
    final payload = await request.readAsString();

    try {
      Map<String, dynamic> data = jsonDecode(payload);
      JsonRPCHttpRequestBody body = JsonRPCHttpRequestBody.fromJson(data);

      StreamController<List<int>> streamController = StreamController<List<int>>();

      _pushData(streamController, EventType.START, jsonEncode({EventType.START: body.method}));

      await tool.streamCall(body.method, body.params, (String event, Map<String, dynamic> data) {
        if(event == EventType.DATA) {
          final responseBody = JsonRPCHttpResponseBody(
              result: data,
              id: body.id
          );
          _pushData(streamController, event, jsonEncode(responseBody.toJson()));
        } else if(event == EventType.ERROR) {     /// Service Error, through Stream onData, then Close Stream
          final error = JsonRPCHttpResponseBodyError(
            code: data['code']?? 500,
            message: data['message']??jsonEncode(data),
          );
          final responseBody = JsonRPCHttpResponseBody(
            result: {},
            id: body.id,
            error: error,
          );
          _pushData(streamController, event, jsonEncode(responseBody.toJson()));
          streamController.close();
        } else if(event == EventType.DONE) {
          streamController.close();
        }
      });

      return Response.ok(streamController.stream, headers: streamHeaders, context: {'shelf.io.buffer_output': false});
    } catch (e) {
      return Response.internalServerError(body: e.toString());  /// FATAL error, will trigger Stream onError
    }
  }

  void _pushData(StreamController<List<int>> streamController, String eventType, String dataString) {
    String data = "event:$eventType\ndata:$dataString\n\n";
    streamController.sink.add(utf8.encode(data));
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

  /// POST /stop
  Future<Response> stop(Request request) async {
    try {
      await tool.dispose();
      final statusInfo = StatusInfo(status: StatusType.STOPPED, serverId: serverId??"NULL");
      final responseBody = statusInfo.toJson();
      unawaited(onStop());
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