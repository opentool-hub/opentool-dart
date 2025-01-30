# OpenTool Specification

Version 1.0.0

## Introduction

The OpenTool Specification (OTS) defines a standard, language-agnostic interface for common tool invocations, allowing humans and computers to discover and understand the capabilities of services without requiring access to source code or documentation. When defined correctly, consumers can understand and use the tool with minimal implementation logic.

### References

The OpenTool Specification references the [OpenAPI3](https://swagger.io/specification/) and [OpenRPC](https://spec.open-rpc.org/) specifications, removing parts unrelated to general-purpose invocations.

### Target

OpenTool is designed for general-purpose program invocation descriptions and is intended to be used with a ToolDriver to allow users to describe functions that can drive specific tools to execute function calls. This can be conveniently used for:
1. Large Language Model `Function Calling`, where specific tools are driven to complete function calls based on descriptions.
2. Workflow description calls, where `OpenWorkflow` descriptions can be used to batch-drive tools to complete function calls.
    - This is useful for allowing Large Language Models to generate `OpenWorkflow` text that can drive tool function calls in a sequential order, suitable for scenarios requiring function calls in a fixed order.

## Objects

### OpenTool Object

| Field     | Type                         | Description                                                                                  |
|-----------|------------------------------|----------------------------------------------------------------------------------------------|
| opentool  | `string`                     | **Required**. The version of the current OpenTool JSON document.                             |
| info      | Info Object                  | **Required**. Information describing the current OpenTool document.                          |
| functions | \[Function Object\]          | **Required**. Information describing the functions supported by the current tool invocation. |
| schemas   | Map<`string`, Schema Object> | Describes `schema` name and the format of input and output.                                  |

### Info Object

| Field       | Type     | Description                                                                                     |
|-------------|----------|-------------------------------------------------------------------------------------------------|
| title       | `string` | **Required**. The title of the current OpenTool JSON document.                                  |
| description | `string` | A more detailed description of the current OpenTool document.                                   |
| version     | `string` | **Required**. The version number of the current document, used for document version management. |

### Function Object

| Field       | Type                 | Description                                                                                                                                                                                                                                                                                                      |
|-------------|----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name        | `string`             | **Required**. The name of the function, containing only a-z, A-Z, 0-9, -, and _ characters, and not exceeding 64 characters. Referenced from OpenAI's function.name description: `The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.` |
| description | `string`             | **Required**. The description of the function, used by humans and large language models to understand the purpose of the current function.                                                                                                                                                                       |
| parameters  | \[Parameter Object\] | **Required**. The description of the input parameters of the function.                                                                                                                                                                                                                                           |
| return      | Return Object        | Description of the function's return parameters. If `null`, it indicates no return value.                                                                                                                                                                                                                        |

### Parameter Object

| Field       | Type          | Description                                                                                                                    |
|-------------|---------------|--------------------------------------------------------------------------------------------------------------------------------|
| name        | `string`      | **Required**. The name of the parameter.                                                                                       |
| description | `string`      | The description of the parameter, used by humans and large language models to understand the purpose of the current parameter. |
| schema      | Schema Object | **Required**. The format of the parameter.                                                                                     |
| required    | `boolean`     | **Required**. Indicates whether the parameter is required.                                                                     |

### Return Object

| Field       | Type          | Description                                                                                                                       |
|-------------|---------------|-----------------------------------------------------------------------------------------------------------------------------------|
| name        | `string`      | **Required**. The name of the return value.                                                                                       |
| description | `string`      | The description of the return value, used by humans and large language models to understand the purpose of the current parameter. |
| schema      | Schema Object | **Required**. The format of the return value.                                                                                     |

### Schema Object

| Field       | Type                         | Description                                                                                                                      |
|-------------|------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| type        | `string`                     | **Required**. The type, options include: `boolean`, `integer`, `number`, `string`, `array`, `object`                             |
| description | `string`                     | The description of the current `type`, used by humans and large language models to understand the purpose of the current format. |
| properties  | Map<`string`, Schema Object> | Required when `type` is `object`, used to describe the structure of the object.                                                  |
| items       | Schema Object                | Required when `type` is `array`, used to describe the format of elements in the array.                                           |
| enum        | \[`string`\]                 | Required when the format has a limited set of possible values.                                                                   |
| required    | \[`string`\]                 | Used to specify which sub-formats must be passed when `type` is `object`.                                                        |
