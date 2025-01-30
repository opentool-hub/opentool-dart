# OpenTool规范

版本 1.0.0

## 介绍

OpenTool规范（OTS）定义了通用工具调用的标准、语言无关接口，允许人类和计算机发现和理解服务的功能，而无需访问源代码和文档。如果定义正确，消费者只需使用最少的实现逻辑即可理解和使用该工具。

### 参考

OpenTool规范参考了[OpenAPI3](https://swagger.io/specification/)与[OpenRPC](https://spec.open-rpc.org/)的规范，去除了与一般性调用无关的部分。

### 目标

OpenTool面向一般性的程序调用描述，并且配合ToolDriver使用，达到用户描述函数，可以驱动具体工具执行函数调用，这将很方便地用于：
1. 大语言模型的`Function Calling`，根据描述，驱动具体工具完成函数调用；
2. 工作流描述调用，结合`OpenWorkflow`描述，可以批量驱动工具完成函数调用。
    - 这对于让大语言模型生成`OpenWorkflow`文本，可以达到按时序驱动工具函数调用的效果。适合于需要按固定顺序调用函数的场景。

## 对象

### OpenTool对象

| 字段        | 类型                      | 描述                          |
|-----------|-------------------------|-----------------------------|
| opentool  | `string`                | **必填**。当前OpenTool的JSON文档版本。 |
| info      | Info对象                  | **必填**。描述当前OpenTool文档的信息。   |
| functions | \[Function对象\]          | **必填**。描述当前工具调用支持的函数信息。     |
| schemas   | Map<`string`, Schema对象> | 描述`schema`名称及其输入输出的格式       |

### Info对象

| 字段          | 类型       | 描述                           |
|-------------|----------|------------------------------|
| title       | `string` | **必填**。当前OpenTool的JSON文档的标题。 |
| description | `string` | 当前OpenTool文档的更详细的描述信息。       |
| version     | `string` | **必填**。当前文档的版本号，用于文档版本管理。    |

### Function对象

| 字段          | 类型              | 描述                                                                                                                                                                                                    |
|-------------|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name        | `string`        | **必填**。函数的名称，只包含a-z、A-Z、0-9、-、_符号，且不超过64个字符。参考自OpenAI的function.name描述：`The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.` |
| description | `string`        | **必填**。函数的描述，用于人类和大语言模型阅读当前function的作用。                                                                                                                                                               |
| parameters  | \[Parameter对象\] | **必填**。函数的传入参数的描述。                                                                                                                                                                                    |
| return      | Return对象        | 函数返回参数的描述。如果为`null`，则表示无返回值                                                                                                                                                                           |

### Parameter对象

| 字段          | 类型        | 描述                         |
|-------------|-----------|----------------------------|
| name        | `string`  | **必填**。参数的名称。              |
| description | `string`  | 参数的描述，用于人类和大语言模型阅读当前参数的作用。 |
| schema      | Schema对象  | **必填**。参数的格式。              |
| required    | `boolean` | **必填**。参数是否必填。             |

### Return对象

| 字段          | 类型        | 描述                          |
|-------------|-----------|-----------------------------|
| name        | `string`  | **必填**。返回值的名称。              |
| description | `string`  | 返回值的描述，用于人类和大语言模型阅读当前参数的作用。 |
| schema      | Schema对象  | **必填**。返回值的格式。              |

### Schema对象

| 字段          | 类型                      | 描述                                                                    |
|-------------|-------------------------|-----------------------------------------------------------------------|
| type        | `string`                | **必填**。类型，可选包括：`boolean`、`integer`、`number`、`string`、`array`、`object` |
| description | `string`                | 当前`type`的描述，用于人类和大语言模型阅读当前格式的作用。                                      |
| properties  | Map<`string`, Schema对象> | 当`type`为`object`时必填，用以描述object的结构。                                    |
| items       | Schema对象                | 当`type`为`array`时必填，用以描述array中元素的格式                                    |
| enum        | \[`string`\]            | 当格式只能取若干可选值时，需要填写。                                                    |
| required    | \[`string`\]            | 当`type`为`object`时，用以确定哪些子格式必须传入。                                      |



