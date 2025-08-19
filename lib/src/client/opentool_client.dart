import 'dart:convert';
import 'package:dio/dio.dart';
import '../../opentool_dart.dart';

abstract class Client {
  Future<Version> version();
  Future<ToolReturn> call(FunctionCall functionCall);
  Future<OpenTool?> load() async => null;
}

class OpenToolClient extends Client {
  bool isSSL = false;
  String host = "localhost";
  int port = DEFAULT_PORT;
  String prefix = DEFAULT_PREFIX;
  String? apiKey;
  late Dio dio;

  OpenToolClient({bool? isSSL, String? host, int? port, this.apiKey}) {
    if (isSSL != null) this.isSSL = isSSL;
    if (host != null && host.isNotEmpty) this.host = host;
    if (port != null && port > 0) this.port = port;

    String protocol = this.isSSL ? 'https' : 'http';
    String baseUrl = '$protocol://${this.host}:${this.port}${this.prefix}';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (apiKey != null && apiKey!.isNotEmpty)
        'Authorization': 'Bearer $apiKey',
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
}