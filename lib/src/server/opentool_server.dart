import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'cli_arguments.dart';
import '../dto.dart';
import '../tool/tool.dart';
import 'controller.dart';
import 'middleware.dart';
import 'route.dart';

abstract class Server {
  Tool tool;

  Server(this.tool);

  Future<void> start();
  Future<void> stop();
}

class OpenToolServer extends Server {
  CliArguments? cliArguments;
  late String version;
  late String host;
  late int port;
  String prefix = DEFAULT_PREFIX;
  late List<String> apiKeys;
  late HttpServer server;
  final _serverCompleter = Completer<HttpServer>();

  OpenToolServer({required Tool tool, this.cliArguments}) : super(tool);

  Future<void> init() async {
    Map<String, dynamic>? cliArgs = cliArguments?.parse();
    Map<String, dynamic>? newCliArgs = await tool.init(cliArgs);
    if(newCliArgs == null) newCliArgs = cliArgs;

    String? toolTag = newCliArgs?[CLI_ARGUMENT_TAG] as String?;
    String? toolHost = newCliArgs?[CLI_ARGUMENT_HOST] as String?;
    int? toolPort = newCliArgs?[CLI_ARGUMENT_PORT]==null? null :int.parse(newCliArgs![CLI_ARGUMENT_PORT]);
    List<String>? toolApiKeys = newCliArgs?[CLI_ARGUMENT_APIKEYS] as List<String>?;
    this.version = toolTag ?? DEFAULT_TOOL_TAG;
    if(toolHost != null && toolHost.isNotEmpty) {
      this.host = toolHost;
    } else {
      this.host = DEFAULT_TOOL_HOST;
    }

    if(toolPort !=null && toolPort > 0) {
      this.port = toolPort;
    } else {
      this.port = DEFAULT_TOOL_PORT;
    }
    if(toolApiKeys != null && toolApiKeys.isNotEmpty) {
      this.apiKeys = toolApiKeys;
    } else {
      this.apiKeys = [];
    }
  }

  @override
  Future<void> start() async {
    await init();

    Controller controller = Controller(tool, version, onStop: stop);

    opentoolRoutes(controller);

    final Router mainRouter = Router();
    mainRouter.mount(prefix, jsonRpcHttpRouter);
    Pipeline pipeline = Pipeline();
    if(apiKeys.isNotEmpty) {
      pipeline = pipeline.addMiddleware(checkAuthorization(this.apiKeys));
    }
    Handler handler = pipeline.addHandler(mainRouter);

    HttpServer server = await serve(handler, host, port);
    print("Start Server: http://${server.address.host}:${server.port}$prefix");

    // DaemonClient daemonClient = DaemonClient();
    // RegisterInfo registerInfo = RegisterInfo(
    //     file: Platform.script.toFilePath(),
    //     host: server.address.host,
    //     port: server.port,
    //     prefix: prefix,
    //     apiKeys: apiKeys,
    //     pid: pid
    // );
    // RegisterResult result = await daemonClient.register(registerInfo);
    // if(result.error != null) {
    //   print("WARNING: Register to daemon failed. (${result.error})");
    //   print("Tool Running in SOLO mode.");
    // } else {
    //   controller.setServerId(result.id);
    //   print("Register to daemon successfully, id: ${result.id}, pid:$pid");
    // }

    _serverCompleter.complete(server);
  }

  @override
  Future<void> stop() async {
    await Future.delayed(Duration(milliseconds: 200));
    final server = await _serverCompleter.future;
    print("Shutting down server...");
    await server.close(force: true);
    print("Server stopped.");
  }
}