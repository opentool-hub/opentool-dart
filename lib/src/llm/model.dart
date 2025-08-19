class FunctionCall {
  late String id;
  late String name;
  late Map<String, dynamic> arguments;

  FunctionCall({required this.id, required this.name, required this.arguments});

  factory FunctionCall.fromJson(Map<String, dynamic> json) {
    return FunctionCall(
        id: json['id'], name: json['name'], arguments: json['arguments']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'arguments': arguments};
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