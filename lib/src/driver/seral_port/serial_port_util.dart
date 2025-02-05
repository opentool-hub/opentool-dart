import 'package:libserialport/libserialport.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'model.dart';

/// IMPORTANT:
/// The lib `libserialport` need environmentVariable LIBSERIALPORT_PATH to be set to the path of the libserialport.dll(Windows) or libserialport.dylib(macOS)

class SerialPortUtil {
  late SerialPort serialPort;

  static List<String> getAvailablePorts() {
    return SerialPort.availablePorts;
  }

  bool openPort(String port, {int baudRate = 9600, int bits = 8, String parity = ParityType.NONE, int stopBits = 1, int rts = 1, int cts = 0, int dsr = 0, int dtr = 1, int xonXoff = 0}) {
    this.serialPort = SerialPort(port);
    this.serialPort.config.baudRate = baudRate;
    this.serialPort.config.bits = bits;

    switch(parity) {
      case ParityType.NONE: this.serialPort.config.parity = SerialPortParity.none;break;
      case ParityType.ODD: this.serialPort.config.parity = SerialPortParity.odd;break;
      case ParityType.EVEN: this.serialPort.config.parity = SerialPortParity.even;break;
      case ParityType.MARK: this.serialPort.config.parity = SerialPortParity.mark;break;
      case ParityType.SPACE: this.serialPort.config.parity = SerialPortParity.space;break;
      default: this.serialPort.config.parity = SerialPortParity.none;
    }

    this.serialPort.config.stopBits = stopBits;
    this.serialPort.config.rts = rts;
    this.serialPort.config.cts = cts;
    this.serialPort.config.dsr = dsr;
    this.serialPort.config.dtr = dtr;
    this.serialPort.config.xonXoff = xonXoff;

    return this.serialPort.openReadWrite();
  }

  int writeCommand(String command, {int timeout = 1000}) {
    List<String> commands = command.trim().split('\n');
    commands = commands.where((element) => element.trim().isNotEmpty).toList();
    int count = 0;
    for (int i = 0; i < commands.length; i++) {
      print(commands[i].trim());
      command = commands[i].trim()+'\r';
      Uint8List commandInBytes = Utf8Encoder().convert(command);
      count = count + this.serialPort.write(commandInBytes,timeout: timeout);
    }
    return count;
  }

  String readData({int bufferBytes = 10000, int timeout = -1}) {
    Uint8List data = this.serialPort.read(bufferBytes,timeout: timeout);
    return utf8.decode(data);
  }

  bool closePort() {
    return this.serialPort.close();
  }

}