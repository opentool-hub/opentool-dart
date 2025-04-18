import 'package:json_annotation/json_annotation.dart';
import 'parameter.dart';
import 'return.dart';

part 'function_model.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class FunctionModel {
  String name;
  String description;
  List<Parameter> parameters;
  @JsonKey(name: "return") Return? return_;

  FunctionModel({required this.name, required this.description, required this.parameters, this.return_});

  factory FunctionModel.fromJson(Map<String, dynamic> json) => _$FunctionModelFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionModelToJson(this);

}