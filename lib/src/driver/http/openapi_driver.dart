import 'http_util.dart';
import 'package:openapi_dart/openapi_dart.dart';
import 'package:opentool_dart/opentool_dart.dart' as ot;

class OpenAPIDriver extends ot.ToolDriver {
  OpenAPI openAPI;
  Map<String, String> functionToolNameMap = {};
  String? authorization;

  OpenAPIDriver(this.openAPI, {this.authorization});

  @override
  List<ot.FunctionModel> parse() {
    List<ot.FunctionModel> functionModelList = [];
    openAPI.paths?.paths?.forEach((String path, PathItem pathItem) {
      /// When use `GET` method, use `queryParams` as parameter in functional calling
      if (pathItem.get != null) {
        String method = HttpAPIMethodType.get;
        String functionName = convertToFunctionName("$method$path");
        List<Parameter>? openapiParameters = pathItem.get!.parameters;
        ot.FunctionModel functionModel = _queryParamsConvertToFunctionModel(
            functionName, pathItem.get!.description ?? "", openapiParameters);
        functionModelList.add(functionModel);
      }

      /// When use `POST` method，use `requestBody` `application/json` as parameter in functional calling
      if (pathItem.post != null) {
        String method = HttpAPIMethodType.post;
        String functionName = convertToFunctionName("$method$path");
        ot.FunctionModel functionModel = _requestBodyConvertToFunctionModel(
            functionName,
            pathItem.post!.description,
            pathItem.post!.requestBody!);
        functionModelList.add(functionModel);
      }

      /// When use `PUT` method，use `requestBody` `application/json` as parameter in functional calling
      if (pathItem.put != null) {
        String method = HttpAPIMethodType.put;
        String functionName = convertToFunctionName("$method$path");
        ot.FunctionModel functionModel = _requestBodyConvertToFunctionModel(
            functionName,
            pathItem.put!.description,
            pathItem.put!.requestBody!
        );
        functionModelList.add(functionModel);
      }

      /// When use `DELETE` method, use `queryParams` as parameter in functional calling
      if (pathItem.delete != null) {
        String method = HttpAPIMethodType.delete;
        String functionName = convertToFunctionName("$method$path");
        List<Parameter>? openapiParameters = pathItem.delete!.parameters;
        ot.FunctionModel functionModel = _queryParamsConvertToFunctionModel(
            functionName,
            pathItem.delete!.description ?? "",
            openapiParameters);
        functionModelList.add(functionModel);
      }
    });
    return functionModelList;
  }

  ot.FunctionModel _requestBodyConvertToFunctionModel(String functionName, String? description, RequestBody requestBody) {
    String bodySchemaType = requestBody.content["application/json"]!.schema!.type;

    if(bodySchemaType == ot.DataType.OBJECT) {
      List<ot.Parameter> otParameters = [];
      List<String>? requiredList = requestBody.content["application/json"]!.schema!.required;
      requestBody.content["application/json"]?.schema?.properties?.forEach((name, schema) {
        bool required = false;
        if(requiredList != null && requiredList.contains(name)) {
          required = true;
        }
        ot.Parameter otParameter = ot.Parameter(
            name: name,
            description: schema.description,
            schema: _toOpenToolSchema(schema),
            required: required
        );
        otParameters.add(otParameter);
      });
      return ot.FunctionModel(
          name: functionName,
          description: description ?? "",
          parameters: otParameters
      );
    } else {
      throw FormatException("requestBody MediaType should be application/json. Schema type should be object");
    }
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

  // ot.Parameter _convertToParameter(String name, Schema schema, bool required) {
  //   // PropertyType propertyType = _PropertyTypeEnumMap[schema.type]!;
  //   if (schema.type == ot.DataType.ARRAY) {
  //     ot.Schema schema0 = ot.Schema(
  //         type: ot.DataType.ARRAY,
  //         description: schema.description ?? "",
  //         enum_: schema.enum_,
  //         items: ot.Schema(
  //           type: schema.items!.type,
  //           description: schema.items!.description,
  //           properties: schema.items!.properties!,
  //           items: schema.items.items,
  //           enum_: schema.items!.enum_
  //         )
  //         // items: _convertToParameter(name, schema.items!, schema.required?.contains(name) ?? false)
  //     );
  //     return ot.Parameter(description: "", schema: schema0, required: required);
  //   } else if (schema.type == ot.DataType.OBJECT) {
  //     Map<String, Parameter> parameters = {};
  //     schema.properties?.forEach((String name, Schema schema0) {
  //       parameters[name] = _convertToParameter(
  //           name, schema0, schema.required?.contains(name) ?? false);
  //     });
  //
  //     return Property(
  //         type: propertyType,
  //         description: schema.description ?? "",
  //         required: required,
  //         enum_: schema.enum_,
  //         properties: properties);
  //   } else {
  //     return Property(
  //         type: propertyType,
  //         description: schema.description ?? "",
  //         required: required,
  //         enum_: schema.enum_);
  //   }
  // }

  ot.FunctionModel _queryParamsConvertToFunctionModel(String functionName, String? description, List<Parameter>? parameters) {
    // Map<String, Property> properties = {};
    // parameters?.forEach((Parameter parameter) {
    //   String key = parameter.name;
    //   Property property = Property(
    //       type: _PropertyTypeEnumMap[parameter.schema?.type ?? "string"]!,
    //       description: parameter.description ?? "",
    //       required: parameter.required ?? false,
    //       enum_: parameter.schema?.enum_);
    //   properties.addAll({key: property});
    // });
    // Parameters opentoolParameters = Parameters(type: "object", properties: properties);

    List<ot.Parameter> otParameters = [];
    parameters?.forEach((Parameter parameter) {
      ot.Parameter opentoolParameters = ot.Parameter(
        name: parameter.name,
        description: parameter.description,
        schema: _toOpenToolSchema(parameter.schema!),
        required: parameter.required??false,
      );
      otParameters.add(opentoolParameters);
    });


    return ot.FunctionModel(
      name: functionName,
      description: description ?? "",
      parameters: otParameters
    );
  }

  String convertToFunctionName(String toolName) {
    String functionName = toolName.replaceAll("-", "--").replaceAll("/", "-");
    functionToolNameMap.addAll({functionName: toolName});
    return functionName;
  }

  String convertToToolName(String functionName) {
    return functionToolNameMap[functionName]!;
  }

  @override
  Future<ot.ToolReturn> call(ot.FunctionCall functionCall) async {
    String toolName = convertToToolName(functionCall.name);
    String method = toolName.split("/").first;
    String baseUrl = openAPI.servers!.first.url;
    String path = toolName.replaceFirst(method, "");
    HttpAPIRequest httpAPIRequest = HttpAPIRequest(
      method: method,
      baseUrl: baseUrl,
      path: path,
      params: functionCall.parameters
    );

    HttpAPIResponse httpAPIResponse = await requestHttpAPI(
      httpAPIRequest,
      authorization: authorization
    );
    return ot.ToolReturn(id: functionCall.id, result: httpAPIResponse.toJson());
  }

  @override
  bool hasFunction(String functionName) {
    return functionToolNameMap.containsKey(functionName);
  }
}

// const _PropertyTypeEnumMap = {
//   'boolean': ot.DataType.boolean,
//   'integer': PropertyType.integer,
//   'number': PropertyType.number,
//   'string': PropertyType.string,
//   'array': PropertyType.array,
//   'object': PropertyType.object
// };

enum ApiKeyType { basic, bearer, original }

String convertToAuthorization(ApiKeyType type, String apiKey) {
  switch (type) {
    case ApiKeyType.basic:
      return "Basic " + apiKey;
    case ApiKeyType.bearer:
      return "Bearer " + apiKey;
    case ApiKeyType.original:
      return apiKey;
  }
}
