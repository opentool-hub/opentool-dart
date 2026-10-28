## 2.1.1

- keep the `/load` not-found marker internal to avoid conflicts with application exception names

## 2.1.0

- resolve local schema references per OpenTool document, including forward references
- support union types, `oneOf`, `anyOf`, `allOf`, and schema-valued `additionalProperties`
- retain the `String`-typed `Schema.type` and legacy schema registry API; expose unions through `typeUnion`
- report unsupported schema keywords and invalid references with their schema paths
- propagate `/load` errors and return null only for an explicit tool-not-found response

## 2.0.1

- default `Parameter.required` to `false` when omitted

## 2.0.0

- following OpenTool Spec 2.0.0, add stream return support
- add stop method

## 1.1.0

- following OpenTool Spec 1.1.0,add Server field

## 0.6.1
- upgrade dependencies and fixed compatibility issues

## 0.6.0
- fixed field name issue: when calling, parameters -> arguments

## 0.5.0
- fixed opentool json format issue
- update openapi and openrpc to the newest version

## 0.4.0
- add MCP stdio driver

## 0.3.0
- add serial port driver supported
- add dynamic libs driver supported

## 0.2.5

- tiny issue fixed

## 0.2.4

- add ToolBreakException

## 0.2.3

- move opentool object from OpenToolDriver constructor to bind()

## 0.2.2

- add FunctionNotSupportedException

## 0.2.1

- adapt openmodbus_dart

## 0.2.0

- refactor referent OpenAPI3 and OpenRPC
- add ToolDrivers

## 0.1.3

- property type array and object support

## 0.1.2

- add property type enum

## 0.1.1

- add load from String

## 0.1.0

- Initial version.
