import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import '../daemon/client.dart';
import '../daemon/dto.dart';
import '../dto.dart';
import '../tool/tool.dart';
import 'controller.dart';
import 'middleware.dart';
import 'route.dart';

abstract class Server {
  Tool tool;
  String version;

  Server(this.tool, this.version);

  Future<void> start();
  Future<void> stop();
}

class OpenToolServer extends Server {
  String ip = "0.0.0.0";
  int port = DEFAULT_PORT;
  String prefix = DEFAULT_PREFIX;
  List<String> apiKeys = const [];
  late HttpServer server;


  OpenToolServer(Tool tool, String version, {String? ip, int? port, List<String>? apiKeys}) : super(tool, version) {
    if(ip != null && ip.isNotEmpty) this.ip = ip;
    if(port != null && port > 0) this.port = port;
    if(apiKeys != null && apiKeys.isNotEmpty) this.apiKeys = apiKeys;
  }

  @override
  Future<void> start() async {
    Controller controller = Controller(tool, version);

    opentoolRoutes(controller);

    final Router mainRouter = Router();
    mainRouter.mount(prefix, jsonRpcHttpRouter);
    Pipeline pipeline = Pipeline();
    if(apiKeys.isNotEmpty) {
      pipeline = pipeline.addMiddleware(checkAuthorization(this.apiKeys));
    }
    Handler handler = pipeline.addHandler(mainRouter);

    HttpServer server = await serve(handler, ip, port);
    print("Start Server: http://${server.address.host}:${server.port}$prefix");
    
    DaemonClient daemonClient = DaemonClient();
    RegisterInfo registerInfo = RegisterInfo(
      file: Platform.script.toFilePath(),
      host: server.address.host,
      port: server.port,
      prefix: prefix,
      apiKeys: apiKeys,
      pid: pid
    );
    RegisterResult result = await daemonClient.register(registerInfo);
    if(result.error != null) {
      print("WARNING: Register to daemon failed. (${result.error})");
      print("Tool Running in SOLO mode.");
    } else {
      print("Register to daemon successfully, id: ${result.id}, pid:$pid");
    }
  }

  @override
  Future<void> stop() async {
    await server.close(force: true);
  }
}