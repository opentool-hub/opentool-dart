import 'dart:async';
import 'package:openmodbus_dart/openmodbus_dart.dart' as mb;
import 'package:opentool_dart/opentool_dart.dart' as ot;
import 'modbus_util.dart';

class OpenModbusDriver extends ot.ToolDriver {
  late mb.OpenModbus openModbus;

  OpenModbusDriver(this.openModbus);

  @override
  List<ot.FunctionModel> parse() {
    List<ot.FunctionModel> functionModelList = openModbus.functions.map((mb.FunctionModel function) {

      ot.Parameter? otParameter;

      if(function.parameter != null) {
        ot.Schema otSchema = ot.Schema(
          type: _convertToDataType(function.parameter!.type)
        );
        otParameter = ot.Parameter(
          name: function.parameter!.name,
          description: function.parameter!.description,
          schema: otSchema,
          required: true
        );
      }

      ot.FunctionModel functionModel = ot.FunctionModel(
          name: function.name,
          description: function.description ?? "",
          parameters: otParameter==null?[]: [otParameter]);
      return functionModel;
    }).toList();
    return functionModelList;
  }

  @override
  Future<ot.ToolReturn> call(ot.FunctionCall functionCall) async {
    mb.FunctionModel targetFunction = openModbus.functions.firstWhere((functionModel) => functionModel.name == functionCall.name);
    ModbusParams modbusParams = _convertToModbusParams(targetFunction);

    ModbusNet? modbusNet;
    ModbusSerial? modbusSerial;
    if (openModbus.server.type == mb.ServerType.tcp ||
        openModbus.server.type == mb.ServerType.udp) {
      mb.NetConfig netConfig = openModbus.server.config as mb.NetConfig;
      modbusNet = ModbusNet(url: netConfig.url, port: netConfig.port);
    } else {
      mb.SerialConfig serialConfig = openModbus.server.config as mb.SerialConfig;
      modbusSerial = ModbusSerial(port: serialConfig.port, baudRate: serialConfig.baudRate);
    }

    ModbusResponse modbusResponse = await requestModbus(
        modbusParams,
        modbusNet: modbusNet,
        modbusSerial: modbusSerial
    );

    return ot.ToolReturn(id: functionCall.id, result: modbusResponse.toJson());
  }

  @override
  bool hasFunction(String functionName) {
    return openModbus.functions
        .where((mb.FunctionModel functionModel) => functionModel.name == functionName)
        .isNotEmpty;
  }

  ModbusParams _convertToModbusParams(mb.FunctionModel function) {
    ElementType elementType;
    switch (function.path.storage) {
      case mb.StorageType.coils:
        elementType = ElementType.coil;
      case mb.StorageType.discreteInput:
        elementType = ElementType.discreteInput;
      case mb.StorageType.inputRegisters:
        elementType = ElementType.inputRegister;
      case mb.StorageType.holdingRegisters:
        elementType = ElementType.holdingRegister;
    }

    ModbusElementParams modbusElementParams = ModbusElementParams(
        name: function.name,
        description: function.description ?? "",
        elementType: elementType,
        address: function.path.address,
        methodType: function.method == mb.MethodType.READ
            ? mb.MethodType.READ
            : mb.MethodType.READ,
        modbusDataType: function.method == mb.MethodType.READ
            ? _convertToModbusDataType(function.parameter!.type)
            : _convertToModbusDataType(function.return_!.type));

    ModbusParams modbusParams = ModbusParams(
        serverType: _convertToModbusServerType(openModbus.server.type),
        slaveId: function.path.slaveId,
        modbusElementParams: modbusElementParams);

    return modbusParams;
  }

  String _convertToModbusServerType(mb.ServerType serverType) {
    Map<mb.ServerType, String> map = {
      mb.ServerType.tcp: ServerType.TCP,
      mb.ServerType.udp: ServerType.UDP,
      mb.ServerType.rtu: ServerType.RTU,
      mb.ServerType.ascii: ServerType.ASCII
    };
    return map[serverType]!;
  }

  String _convertToModbusDataType(String dataType) {
    Map<String, String> map = {
      mb.DataType.BOOL: ModbusDataType.BOOL,
      mb.DataType.INT16: ModbusDataType.INT16,
      mb.DataType.INT32: ModbusDataType.INT32,
      mb.DataType.UINT16: ModbusDataType.UINT16,
      mb.DataType.UINT32: ModbusDataType.UINT32,
      mb.DataType.STRING: ModbusDataType.STRING
    };
    return map[dataType]!;
  }

  String _convertToDataType(String modbusDataType) {
    Map<String, String> map = {
      ModbusDataType.BOOL: ot.DataType.BOOLEAN,
      ModbusDataType.INT16: ot.DataType.INTEGER,
      ModbusDataType.INT32: ot.DataType.INTEGER,
      ModbusDataType.UINT16: ot.DataType.INTEGER,
      ModbusDataType.UINT32: ot.DataType.INTEGER,
      ModbusDataType.STRING: ot.DataType.STRING
    };
    return map[modbusDataType]!;
  }
}


