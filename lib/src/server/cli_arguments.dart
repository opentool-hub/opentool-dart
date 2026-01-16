import 'package:args/args.dart';
import '../dto.dart';

class CliArguments {
  ArgParser _argParser = ArgParser();
  late List<String> _args;

  CliArguments(List<String> args) {
    this._args = args;
    _argParser.addOption(
      '$CLI_ARGUMENT_TAG',
      help: 'opentool-server version, same as tag',
    );
    _argParser.addOption('$CLI_ARGUMENT_HOST', help: '0.0.0.0 or 127.0.0.1');
    _argParser.addOption(
      '$CLI_ARGUMENT_PORT',
      help: 'opentool-server http port',
    );
    _argParser.addMultiOption(
      '$CLI_ARGUMENT_APIKEYS',
      help: 'opentool-server http secure api keys',
    );
  }

  CliArguments addCustomOption(
    String name, {
    String? abbr,
    String? help,
    String? valueHelp,
    Iterable<String>? allowed,
    Map<String, String>? allowedHelp,
    String? defaultsTo,
    void Function(String?)? callback,
    bool mandatory = false,
    bool hide = false,
    List<String> aliases = const [],
  }) {
    _argParser.addOption(
      name,
      abbr: abbr,
      help: help,
      valueHelp: valueHelp,
      allowed: allowed,
      allowedHelp: allowedHelp,
      defaultsTo: defaultsTo,
      callback: callback,
      mandatory: mandatory,
      hide: hide,
      aliases: aliases,
    );
    return this;
  }

  CliArguments addCustomMultiOption(
    String name, {
    String? abbr,
    String? help,
    String? valueHelp,
    Iterable<String>? allowed,
    Map<String, String>? allowedHelp,
    Iterable<String>? defaultsTo,
    void Function(List<String>)? callback,
    bool splitCommas = true,
    bool hide = false,
    List<String> aliases = const [],
  }) {
    _argParser.addMultiOption(
      name,
      abbr: abbr,
      help: help,
      valueHelp: valueHelp,
      allowed: allowed,
      allowedHelp: allowedHelp,
      defaultsTo: defaultsTo,
      callback: callback,
      hide: hide,
      aliases: aliases,
    );
    return this;
  }

  Map<String, dynamic> parse() {
    ArgResults results = _argParser.parse(_args);
    final Map<String, dynamic> map = <String, dynamic>{};

    for (final key in results.options) {
      final value = results[key];

      if (value is List) {
        map[key] = value;
      } else if (value != null) {
        map[key] = value.toString();
      }
    }

    return map;
  }
}
