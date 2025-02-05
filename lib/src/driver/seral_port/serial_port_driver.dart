import 'package:opentool_dart/opentool_dart.dart';
import 'model.dart';
import 'serial_port_util.dart';

class SerialPortDriver extends ToolDriver {
  SerialPortUtil serialUtil = SerialPortUtil();
  List<FunctionModel> functionModelList = [];

  @override
  Future<ToolReturn> call(FunctionCall functionCall) async {
    try {
      if (functionCall.name == "getAvailablePorts") {
        List<String> availablePorts = SerialPortUtil.getAvailablePorts();
        return ToolReturn(
            id: functionCall.id, result: {"availablePorts": availablePorts});
      } else if (functionCall.name == "openPort") {
        String name = functionCall.parameters["name"];
        int baudRate = functionCall.parameters["baudRate"] ?? 9600;
        int bits = functionCall.parameters["bits"] ?? 8;
        String parity = functionCall.parameters["parity"] ?? "none";
        int stopBits = functionCall.parameters["stopBits"] ?? 1;
        int rts = functionCall.parameters["rts"] ?? 1;
        int cts = functionCall.parameters["cts"] ?? 0;
        int dtr = functionCall.parameters["dtr"] ?? 1;
        int dsr = functionCall.parameters["dsr"] ?? 1;
        int xonXoff = functionCall.parameters["xonXoff"] ?? 0;
        bool openStatus = serialUtil.openPort(name, baudRate: baudRate,
            bits: bits,
            parity: parity,
            stopBits: stopBits,
            rts: rts,
            cts: cts,
            dtr: dtr,
            dsr: dsr,
            xonXoff: xonXoff);
        return ToolReturn(
            id: functionCall.id, result: {"openStatus": openStatus});
      } else if (functionCall.name == "writeCommand") {
        String command = functionCall.parameters["command"];
        int timeout = functionCall.parameters["timeout"] ?? 1000;
        int byteWritenCount = serialUtil.writeCommand(
            command, timeout: timeout);
        return ToolReturn(
            id: functionCall.id, result: {"byteWritenCount": byteWritenCount});
      } else if (functionCall.name == "readData") {
        int bufferBytes = functionCall.parameters["bufferBytes"] ?? 10000;
        int timeout = functionCall.parameters["timeout"] ?? -1;
        String data = serialUtil.readData(
            bufferBytes: bufferBytes, timeout: timeout);
        return ToolReturn(id: functionCall.id, result: {"data": data});
      } else if (functionCall.name == "closePort") {
        bool closeStatus = serialUtil.closePort();
        return ToolReturn(
            id: functionCall.id, result: {"close status": closeStatus});
      } else {
        return ToolReturn(id: functionCall.id,
            result: FunctionNotSupportedException(
                functionName: functionCall.name).toJson());
      }
    } catch (e) {
      return ToolReturn(id: functionCall.id, result: {"error": e.toString()});
    }
  }

  @override
  bool hasFunction(String functionName) {
    return this.functionModelList.any((element) => element.name == functionName);
  }

  @override
  List<FunctionModel> parse() {
    this.functionModelList = [
      FunctionModel(
        name: "getAvailablePorts", 
        description: "Get available serial ports list.", 
        parameters: [], 
        return_: Return(
          name: "availablePorts", 
          description: "Available serial ports list", 
          schema: Schema(type: SchemaType.ARRAY, description: "serial port name", items: Schema(type: SchemaType.STRING)
          )
        )
      ),
      FunctionModel(
        name: "openPort", 
        description: "open the serial port by name.", 
        parameters: [
          Parameter(name: "name", description: "Serial port name", schema: Schema(type: SchemaType.STRING), required: true),
          Parameter(name: "baudRate", description: "Baud rate, default 9600", schema: Schema(type: SchemaType.INTEGER)),
          Parameter(name: "bits", description: "Data bits, default 8", schema: Schema(type: SchemaType.INTEGER)),
          Parameter(name: "parity", description: "Parity setting, include `${ParityType.NONE}`, `${ParityType.ODD}`, `${ParityType.EVEN}`, `${ParityType.MARK}`, `${ParityType.SPACE}`, default `${ParityType.NONE}`", schema: Schema(type: SchemaType.STRING)),
          Parameter(name: "stopBits", description: "Stop bits, default 1", schema: Schema(type: SchemaType.INTEGER)),
          Parameter(name: "rts", description: "RTS pin behaviour, default 1", schema: Schema(type: SchemaType.INTEGER)),
          Parameter(name: "cts", description: "CTS pin behaviour, default 0", schema: Schema(type: SchemaType.INTEGER)),
          Parameter(name: "dtr", description: "DTR pin behaviour, default 1", schema: Schema(type: SchemaType.INTEGER)),
          Parameter(name: "dsr", description: "DSR pin behaviour, default 1", schema: Schema(type: SchemaType.INTEGER)),
          Parameter(name: "xonXoff", description: "XON/XOFF, default 0", schema: Schema(type: SchemaType.INTEGER))
        ],
        return_: Return(
          name: "openStatus",
          description: "Open is successful or not",
          schema: Schema(type: SchemaType.BOOLEAN, description: "false for failure, 1 for successful")
        )
      ),
      FunctionModel(
        name: "writeCommand",
        description: "Write commands included '/n' to serial port has been opened.",
        parameters: [
          Parameter(name: "command", description: "Command to write, can be with '/n'.", schema: Schema(type: SchemaType.STRING), required: true),
          Parameter(name: "timeout", description: "Timeout for write command, default 1000 ms", schema: Schema(type: SchemaType.INTEGER))
        ],
        return_: Return(
            name: "byteWritenCount",
            description: "The count of bytes written to serial port",
            schema: Schema(type: SchemaType.INTEGER)
        )
      ),
      FunctionModel(
        name: "readData",
        description: "Read data string by utf-8 from serial port.",
        parameters: [
          Parameter(name: "bufferBytes", description: "buffer size in bytes, default 10000", schema: Schema(type: SchemaType.INTEGER)),
          Parameter(name: "timeout", description: "Timeout for read data, unit ms, default -1", schema: Schema(type: SchemaType.INTEGER))
        ],
        return_: Return(
          name: "data",
          description: "Data read from serial port",
          schema: Schema(type: SchemaType.STRING)
        )
      ),
      FunctionModel(
        name: "closePort",
        description: "Close current serial port.",
        parameters: [],
        return_: Return(
            name: "close status",
            description: "Close is successful or not",
            schema: Schema(type: SchemaType.BOOLEAN, description: "false for failure, 1 for successful")
        )
      ),
    ];
    return this.functionModelList;
  }
  
}