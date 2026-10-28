import 'package:json_annotation/json_annotation.dart';
import 'function_model.dart';
import 'info.dart';
import 'server.dart';
import 'schema.dart';

part 'opentool.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
class OpenTool {
  String opentool;
  Info info;
  ServerConfig? server;
  List<FunctionModel> functions;
  Map<String, Schema>? schemas;

  OpenTool({
    required this.opentool,
    required this.info,
    this.server,
    required this.functions,
    this.schemas,
  });

  factory OpenTool.fromJson(Map<String, dynamic> json) {
    final rawSchemas = json['schemas'];
    if (rawSchemas != null && rawSchemas is! Map<String, dynamic>) {
      throw const FormatException('schemas: expected an object.');
    }
    final schemaResolver = SchemaResolver(rawSchemas as Map<String, dynamic>?);
    final parsedSchemas = rawSchemas == null
        ? null
        : schemaResolver.resolveAll();

    final rawFunctions = json['functions'];
    if (rawFunctions is! List) {
      throw const FormatException('functions: expected an array.');
    }
    final functions = <FunctionModel>[];
    for (var i = 0; i < rawFunctions.length; i++) {
      final rawFunction = rawFunctions[i];
      if (rawFunction is! Map<String, dynamic>) {
        throw FormatException('functions[$i]: expected an object.');
      }
      functions.add(
        FunctionModel.fromJson(
          rawFunction,
          schemaResolver: schemaResolver,
          path: 'functions[$i]',
        ),
      );
    }

    return OpenTool(
      opentool: json['opentool'] as String,
      info: Info.fromJson(json['info'] as Map<String, dynamic>),
      server: json['server'] == null
          ? null
          : ServerConfig.fromJson(json['server'] as Map<String, dynamic>),
      functions: functions,
      schemas: parsedSchemas,
    );
  }

  Map<String, dynamic> toJson() => _$OpenToolToJson(this);
}
