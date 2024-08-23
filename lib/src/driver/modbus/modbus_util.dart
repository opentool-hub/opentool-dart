import 'dart:async';
import 'package:modbus_client_serial/modbus_client_serial.dart';
import 'package:modbus_client_udp/modbus_client_udp.dart';
import 'package:modbus_client/modbus_client.dart';
import 'package:modbus_client_tcp/modbus_client_tcp.dart';

class ServerType {
  static const String TCP = "tcp";
  static const String UDP = "udp";
  static const String RTU = "rtu";
  static const String ASCII = "ascii";
}

class ModbusDataType {
  static const String BOOL = "bool";
  static const String INT16 = "int16";
  static const String INT32 = "int32";
  static const String UINT16 = "uint16";
  static const String UINT32 = "uint32";
  static const String STRING = "string";
}

class MethodType {
  static const String READ = "read";
  static const String WRITE = "write";
}

enum ElementType { discreteInput, coil, inputRegister, holdingRegister}

class ModbusNet {
  late String url;
  late int port;
  ModbusNet({required this.url, required this.port});
}

class ModbusSerial {
  late String port;
  late int baudRate;
  ModbusSerial({required this.port, required this.baudRate});
}

class ModbusElementParams {
  String name;
  String description;
  ElementType elementType;
  int address;
  int? byteCount;
  String methodType;
  dynamic value;
  String modbusDataType;
  String uom;
  double multiplier;

  ModbusElementParams({
    required this.name,
    required this.description,
    required this.elementType,
    required this.address,
    this.byteCount,
    required this.methodType,
    this.value,
    required this.modbusDataType,
    this.uom = "",
    this.multiplier = 1
  });
}

class ModbusParams {
  String serverType;
  int slaveId;
  ModbusElementParams modbusElementParams;

  ModbusParams({
    required this.serverType,
    required this.slaveId,
    required this.modbusElementParams
  });
}

class ModbusResponse {
  int statusCode;
  dynamic value;
  String message;
  ModbusResponse({required this.statusCode, this.value, required this.message});

  Map<String, dynamic> toJson() => {'statusCode': statusCode, 'value': value, 'message': message};
}

Future<ModbusResponse> requestModbus(ModbusParams modbusParams, {ModbusNet? modbusNet, ModbusSerial? modbusSerial}) {
  ModbusClient modbusClient;
  if (modbusParams.serverType == ServerType.TCP) {
    modbusClient = ModbusClientTcp(
        modbusNet!.url,
        serverPort: modbusNet.port,
        unitId: modbusParams.slaveId
    );
  } else if (modbusParams.serverType == ServerType.RTU) {
    modbusClient = ModbusClientSerialRtu(
      portName: modbusSerial!.port,
      baudRate: _convertToSerialBaudRate(modbusSerial.baudRate)
    );
  } else if (modbusParams.serverType == ServerType.ASCII) {
    modbusClient = ModbusClientSerialAscii(
      portName: modbusSerial!.port,
      baudRate: _convertToSerialBaudRate(modbusSerial.baudRate)
    );
  } else {
    modbusClient = ModbusClientUdp(
      modbusNet!.url,
      serverPort: modbusNet.port,
      unitId: modbusParams.slaveId
    );
  }

  Completer<ModbusResponse> completer = Completer();
  int? statusCode = null;
  String? message = null;
  dynamic value = null;

  Function(ModbusElement)? onUpdate;
  ModbusElement modbusElement;
  ModbusElementRequest modbusElementRequest;
  if (modbusParams.modbusElementParams.methodType == MethodType.READ) {
    onUpdate = (ModbusElement modbusElement) {
      message = modbusElement.toString();
      value = modbusElement.value;
      if (statusCode != null && message != null) {
        completer.complete(ModbusResponse(statusCode: statusCode!, value: value, message: message!));
      }
    };
    modbusElement = buildModbusElement(modbusParams.modbusElementParams, onUpdate);
    modbusElementRequest = modbusElement.getReadRequest();
  } else {
    modbusElement = buildModbusElement(modbusParams.modbusElementParams, onUpdate);
    modbusElementRequest = modbusElement.getWriteRequest(modbusParams.modbusElementParams.value);
  }

  modbusClient.send(modbusElementRequest).then((ModbusResponseCode modbusResponseCode) {
    statusCode = modbusResponseCode.code;
    if (modbusParams.modbusElementParams.methodType == MethodType.READ) {
      /// Read when element not null
      if (statusCode != null && message != null) {
        completer.complete(ModbusResponse(statusCode: statusCode!, value: value, message: message!));
      }
      if (statusCode != 0x00) {
        /// If read error, return error info.
        completer.complete(ModbusResponse(statusCode: statusCode!, message: modbusResponseCode.name));
      }
    } else {
      completer.complete(ModbusResponse(statusCode: statusCode!, message: modbusResponseCode.name));
    }
  });

  return completer.future;
}

ModbusElement buildModbusElement(ModbusElementParams modbusElementParams, Function(ModbusElement)? onUpdate) {
  ModbusElementType modbusElementType = _convertToModbusElementType(modbusElementParams.elementType);
  switch (modbusElementParams.modbusDataType) {
    case ModbusDataType.BOOL:
      return ModbusBitElement(
        name: modbusElementParams.name,
        description: modbusElementParams.description,
        address: modbusElementParams.address,
        type: modbusElementType,
        onUpdate: onUpdate
      );
    case ModbusDataType.INT16:
      return ModbusInt16Register(
        name: modbusElementParams.name,
        description: modbusElementParams.description,
        address: modbusElementParams.address,
        type: modbusElementType,
        onUpdate: onUpdate,
        uom: modbusElementParams.uom,
        multiplier: modbusElementParams.multiplier
      );
    case ModbusDataType.INT32:
      return ModbusInt32Register(
        name: modbusElementParams.name,
        description: modbusElementParams.description,
        address: modbusElementParams.address,
        type: modbusElementType,
        onUpdate: onUpdate,
        uom: modbusElementParams.uom,
        multiplier: modbusElementParams.multiplier
      );
    case ModbusDataType.UINT16:
      return ModbusUint16Register(
        name: modbusElementParams.name,
        description: modbusElementParams.description,
        address: modbusElementParams.address,
        type: modbusElementType,
        onUpdate: onUpdate,
        uom: modbusElementParams.uom,
        multiplier: modbusElementParams.multiplier
      );
    case ModbusDataType.UINT32:
      return ModbusUint32Register(
        name: modbusElementParams.name,
        description: modbusElementParams.description,
        address: modbusElementParams.address,
        type: modbusElementType,
        onUpdate: onUpdate,
        uom: modbusElementParams.uom,
        multiplier: modbusElementParams.multiplier
      );
    default :
      return ModbusBytesRegister(
        name: modbusElementParams.name,
        description: modbusElementParams.description,
        address: modbusElementParams.address,
        byteCount: modbusElementParams.byteCount!,
        type: modbusElementType,
        onUpdate: onUpdate
      );
  }
}

SerialBaudRate _convertToSerialBaudRate(int number) {
  return SerialBaudRate.values.firstWhere(
    (e) => e.toString() == 'SerialBaudRate.b$number',
    orElse: () => throw ArgumentError('Unrecognized enum value: $number')
  );
}

ModbusElementType _convertToModbusElementType(ElementType elementType) {
  switch(elementType) {
    case ElementType.discreteInput: return ModbusElementType.discreteInput;
    case ElementType.coil: return ModbusElementType.coil;
    case ElementType.inputRegister: return ModbusElementType.inputRegister;
    case ElementType.holdingRegister: return ModbusElementType.holdingRegister;
  }
}
