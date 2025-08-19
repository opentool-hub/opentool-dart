import 'dart:convert';
import 'package:dio/dio.dart';
import 'dto.dart';

const int DAEMON_DEFAULT_PORT = 19627;
const String DAEMON_DEFAULT_PREFIX = "/opentool-daemon";

class DaemonClient {
  String protocol = 'http';
  String host = "localhost";
  int port = DAEMON_DEFAULT_PORT;
  String prefix = DAEMON_DEFAULT_PREFIX;
  late Dio dio;

  DaemonClient({int? port}) {
    if (port != null && port > 0) this.port = port;
    String baseUrl = '$protocol://${host}:${this.port}${prefix}';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    dio = Dio(BaseOptions(baseUrl: baseUrl, headers: headers));
  }

  Future<RegisterResult> register(RegisterInfo registerInfo) async {
    try {
      Response response = await dio.post('/register', data: jsonEncode(registerInfo.toJson()),);

      final data = response.data;
      return RegisterResult.fromJson(data);
    } on DioException catch (e) {
      return RegisterResult(id: "-1", error: e.message);
    }
  }
}