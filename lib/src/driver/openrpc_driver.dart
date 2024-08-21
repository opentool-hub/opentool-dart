import 'package:openrpc_dart/openrpc_dart.dart';
import 'package:opentool_dart/opentool_dart.dart' as ot;

abstract class OpenRPCDriver extends ot.ToolDriver {
  OpenRPC openRPC;

  OpenRPCDriver(this.openRPC);

  @override
  List<ot.FunctionModel> parse() {
    List<ot.FunctionModel> functionModelList = [];
    openRPC.methods.forEach((Method method) {
      List<ot.Parameter> opentoolParameters = [];
      method.params.forEach((ContentDescriptor contentDescriptor) {
        ot.Parameter otParameter = ot.Parameter(
          name: contentDescriptor.name,
          description: contentDescriptor.description,
          schema: _toOpenToolSchema(contentDescriptor.schema),
          required: contentDescriptor.required
        );

        opentoolParameters.add(otParameter);
      });
      ot.FunctionModel functionModel = ot.FunctionModel(
          name: method.name,
          description: method.description ?? "",
          parameters: opentoolParameters
      );
      functionModelList.add(functionModel);
    });
    return functionModelList;
  }

  ot.Schema _toOpenToolSchema(Schema schema) {
    Map<String, ot.Schema>? otProperties;
    if (schema.properties != null) {
      otProperties = {};
      schema.properties!.forEach((key, value) {
        otProperties![key] = _toOpenToolSchema(value);
      });
    }

    return ot.Schema(
        type: schema.type,
        description: schema.description,
        properties: otProperties,
        items: schema.items == null? null: _toOpenToolSchema(schema.items!),
        enum_: schema.enum_,
        required: schema.required
    );
  }
}
