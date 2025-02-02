import 'dart:io';

class FunctionInfo {
  File dynFile;
  String name;
  List<ParameterInfo> parameterInfoList;

  FunctionInfo({required this.dynFile, required this.name, required this.parameterInfoList});
}

class ParameterInfo {
  String name;
  String type;  // boolean, integer, number, string
  String cDataType; // void, bool, char, unsigned char, short, unsigned short, int, unsigned int, long, unsigned long, long long, unsigned long long, float, double
  bool isIn;
  bool isPointer;
  dynamic value;

  ParameterInfo({required this.name, required this.type, required this.cDataType, required this.isIn, required this.isPointer, required this.value});
}

class FunctionInfoWithId {
  String id;
  FunctionInfo functionInfo;

  FunctionInfoWithId({required this.id, required this.functionInfo});
}