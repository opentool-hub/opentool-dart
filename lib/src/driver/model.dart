class FunctionCall {
  late String id;
  late String name;
  late Map<String, dynamic> parameters;

  FunctionCall({required this.id, required this.name, required this.parameters});

  factory FunctionCall.fromJson(Map<String, dynamic> json) {
    return FunctionCall(
        id: json['id'], name: json['name'], parameters: json['parameters']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'parameters': parameters};
  }
}

class ToolReturn {
  late String id;
  late Map<String, dynamic> result;

  ToolReturn({required this.id, required this.result});

  factory ToolReturn.fromJson(Map<String, dynamic> json) {
    return ToolReturn(id: json['id'], result: json['result']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'result': result};
  }
}