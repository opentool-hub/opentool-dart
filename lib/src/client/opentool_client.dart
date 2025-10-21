import 'dart:convert';
import 'dart:io' as io;
import 'package:dio/dio.dart';
import '../../opentool_dart.dart';

abstract class Client {
  Future<Version> version();
  Future<ToolReturn> call(FunctionCall functionCall);
  Future<void> streamCall(FunctionCall functionCall, void Function(String event, ToolReturn toolReturn) onToolReturn);
  Future<OpenTool?> load() async => null;
  Future<StatusInfo?> stop();
}

class OpenToolClient extends Client {
  bool isSSL = false;
  late String host;
  late int port;
  String prefix = DEFAULT_PREFIX;
  String? toolApiKey;
  late Dio dio;

  OpenToolClient({bool? isSSL, required String toolHost, required int toolPort, this.toolApiKey}) {
    if (isSSL != null) this.isSSL = isSSL;
    if (toolHost.isNotEmpty) this.host = toolHost;
    if (toolPort > 0) this.port = toolPort;

    String protocol = this.isSSL ? 'https' : 'http';
    String baseUrl = '$protocol://${this.host}:${this.port}${this.prefix}';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (toolApiKey != null && toolApiKey!.isNotEmpty)
        'Authorization': 'Bearer $toolApiKey',
    };

    dio = Dio(BaseOptions(baseUrl: baseUrl, headers: headers));
  }

  @override
  Future<Version> version() async {
    try {
      Response response = await dio.get('/version');
      return Version.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw OpenToolServerUnauthorizedException();
      }
      throw OpenToolServerNoAccessException();
    }
  }

  @override
  Future<ToolReturn> call(FunctionCall functionCall) async {
    Map<String, dynamic> result = await _callJsonRpcHttp(
      functionCall.id,
      functionCall.name,
      functionCall.arguments,
    );
    return ToolReturn(id: functionCall.id, result: result);
  }

  Future<Map<String, dynamic>> _callJsonRpcHttp(
    String id,
    String method,
    Map<String, dynamic> params,
    ) async {
    JsonRPCHttpRequestBody requestBody = JsonRPCHttpRequestBody(
      id: id,
      method: method,
      params: params,
    );

    try {
      Response response = await dio.post('/call', data: jsonEncode(requestBody.toJson()),);

      final data = response.data;
      final responseBody = data is Map<String, dynamic>
          ? JsonRPCHttpResponseBody.fromJson(data)
          : JsonRPCHttpResponseBody.fromJson(jsonDecode(data));

      if (responseBody.error != null) {
        throw OpenToolServerCallException(responseBody.error!.message);
      }

      return responseBody.result;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw OpenToolServerUnauthorizedException();
      }
      throw OpenToolServerNoAccessException();
    }
  }


  Future<void> streamCall(FunctionCall functionCall, void Function(String event, ToolReturn toolReturn) onToolReturn) async {

    Stream<String> sseStream = await _streamCallJsonRpcHttp(
        functionCall.id,
        functionCall.name,
        functionCall.arguments
    );

    sseStream.listen((sseString) {
      _onData(sseString, (String event, Map<String, dynamic> data) {
        if(event == EventType.START) {
          onToolReturn(event, ToolReturn(id: functionCall.id, result: data));
        } else if(event == EventType.DATA || event == EventType.ERROR) {
          JsonRPCHttpResponseBody responseBody = JsonRPCHttpResponseBody.fromJson(data);
          if (responseBody.error != null) {
            throw OpenToolServerCallException(responseBody.error!.message);
          }
          onToolReturn(event, ToolReturn(id: functionCall.id, result: responseBody.result));
        }
      });
    },
        onDone: () {
          onToolReturn(EventType.DONE, ToolReturn(id: functionCall.id, result: {EventType.DONE: functionCall.name}));
        },
        onError: (e) {
          throw OpenToolServerCallException(e.toString());
        }
    );
  }

  Future<Stream<String>> _streamCallJsonRpcHttp(
      String id,
      String method,
      Map<String, dynamic> params
      ) async {
    JsonRPCHttpRequestBody requestBody = JsonRPCHttpRequestBody(
      id: id,
      method: method,
      params: params,
    );

    try {
      Uri uri = Uri.parse('${dio.options.baseUrl}/streamCall');
      io.HttpClient httpClient = io.HttpClient();

      io.HttpClientRequest request = await httpClient.postUrl(uri);

      request.headers.add(io.HttpHeaders.acceptHeader, 'text/event-stream');
      request.headers.add(io.HttpHeaders.contentTypeHeader, 'application/json');
      if(toolApiKey != null) request.headers.add(io.HttpHeaders.authorizationHeader, 'Bearer $toolApiKey');

      Map<String, dynamic> data = requestBody.toJson();

      request.add(utf8.encode(jsonEncode(data)));

      io.HttpClientResponse response = await request.close();

      Stream<String> stream = response.transform(utf8.decoder);
      return stream;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw OpenToolServerUnauthorizedException();
      }
      throw OpenToolServerNoAccessException();
    }
  }

  @override
  Future<OpenTool?> load() async {
    try {
      final response = await dio.get('/load');
      final data = response.data;
      final parsed = data is Map<String, dynamic> ? data : jsonDecode(data);
      return OpenTool.fromJson(parsed);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<StatusInfo?> stop() async {
    try {
      final response = await dio.post('/stop');
      final data = response.data;
      final parsed = data is Map<String, dynamic> ? data : jsonDecode(data);
      return StatusInfo.fromJson(parsed);
    } catch (_) {
      return null;
    }
  }
}

Future<void> _onData(String data, void Function(String event, Map<String, dynamic> data) onEvent) async {
  // final eventRegex = RegExp(r"^(?:event:\s*(?<event>.+?)\r?\n)?data:\s*(?<data>\{.*\})$");
  final eventRegex = RegExp(r'event:(\w+)\ndata:(.*?)\n\n');
  final matches = eventRegex.allMatches(data);

  for (var match in matches) {
    final eventName = match.group(1);
    final eventData = match.group(2);

    if(eventName != null && eventData != null) {
      onEvent(eventName, jsonDecode(eventData));
    }
  }

}