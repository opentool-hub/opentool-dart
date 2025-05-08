import 'dart:io';

import 'package:opendyn_dart/opendyn_dart.dart' as od;
import 'package:opentool_dart/opentool_dart.dart' as ot;
import 'package:opentool_dart/src/driver/dyn/model.dart';
import '../model.dart';
import '../tool_driver.dart';
import 'isolate_async.dart';

class OpenDynDriver extends ToolDriver {
  od.OpenDyn openDyn;
  IsolateAsync isolateAsync = IsolateAsync();
  File dynFile;

  OpenDynDriver({required this.openDyn, required this.dynFile});

  @override
  Future<ToolReturn> call(FunctionCall functionCall) async {
    if(!isolateAsync.hasInit) {
      await isolateAsync.init();
    }

    od.FunctionModel odFunctionModel = openDyn.functions.firstWhere((od.FunctionModel odFunctionModel) => odFunctionModel.name == functionCall.name);

    List<ParameterInfo> parameterInfoList = [];
    functionCall.arguments.forEach((parameterName, parameterValue){
      od.Parameter odParameter = odFunctionModel.parameters.firstWhere((od.Parameter odParameter) => odParameter.name == parameterName);

      ParameterInfo parameterInfo = ParameterInfo(
          name: parameterName,
          type: odParameter.schema.type,
          cDataType: odParameter.schema.cType.type,
          isIn: odParameter.isIn,
          isPointer: odParameter.schema.cType.isPointer,
          value: parameterValue
      );

      parameterInfoList.add(parameterInfo);

    });

    FunctionInfoWithId functionInfoWithId = FunctionInfoWithId(
        id: functionCall.id,
        functionInfo: FunctionInfo(
          dynFile: dynFile,
          name: functionCall.name,
          parameterInfoList: parameterInfoList
        )
    );
    return await isolateAsync.sendMessage(functionInfoWithId);
  }

  Future<void> dispose() async{
    isolateAsync.dispose();
  }

  @override
  bool hasFunction(String functionName) {
    return openDyn.functions.any((functionModel) => functionModel.name == functionName);
  }

  @override
  List<ot.FunctionModel> parse() {
    return openDyn.functions.map((od.FunctionModel odFunction) {
      List<ot.Parameter> otParameters = odFunction.parameters.map((od.Parameter odParameter) {
        ot.Schema otSchema = ot.Schema(
          type: odParameter.schema.type,
          description: odParameter.description,
        );
        return ot.Parameter(
          name: odParameter.name,
          description: odParameter.description,
          schema: otSchema,
          required: odParameter.required
        );
      }).toList();

      ot.Return? otReturn;
      if(odFunction.return_ != null ) {
        otReturn = ot.Return(
            name: odFunction.return_!.name,
            description: odFunction.return_!.description,
            schema: ot.Schema(
                type: odFunction.return_!.schema.type,
                description: odFunction.return_!.schema.description
            )
        );
      }

      ot.FunctionModel functionModel = ot.FunctionModel(
          name: odFunction.name,
          description: odFunction.description,
          parameters: otParameters,
          return_: otReturn
      );
      return functionModel;
      }
    ).toList();
  }
}

// Future<void> main() async {
//   OpenDynDriver openDyn = OpenDynDriver();
//   FunctionCall functionCall = FunctionCall(id: "1", name: "test", parameters: {"param1": "value1"});
//   ToolReturn toolReturn = await openDyn.call(functionCall);
//   print(toolReturn.toJson());
//   await openDyn.dispose();
// }