# Migration to 3.0.0

Version 3.0 replaces the hand-written JSON Schema subset with a standards-aware
schema model and validator. It requires Dart SDK `>=3.13.0 <4.0.0`. Schemas
without `$schema` use Draft 2020-12. A supported `$schema` URI selects its
declared dialect.

## Schema JSON values

`Schema.fromJson` accepts either a schema object or a boolean schema. Because
JSON Schema allows both, `Schema.toJson()` now returns `Object` instead of
`Map<String, dynamic>`. Narrow the value when the caller requires an object:

```dart
final json = schema.toJson();
if (json is Map<String, dynamic>) {
  // Read object-schema keywords.
}
```

The schema wrapper preserves its source JSON, including annotations and
extension keywords. `$ref` values remain references in serialized output;
they are no longer expanded while loading. OpenTool `#/schemas/<name>`
references continue to resolve for validation.

Schema keyword accessors are now read-only. Update the JSON value before
constructing a `Schema` when a schema needs to change.

## Validate function arguments

Schema loading compiles the schema. Call `validate` or `isValid` when checking
an argument value. `format` is treated as an annotation by default; set
`validateFormats: true` to enable the engine's built-in format assertions.
Validation does not insert `default` values or transform the instance.

```dart
final result = parameter.schema.validate(arguments['value']);
if (!result.isValid) {
  print(result.errors);
}
```

## External references

Pass a synchronous resource resolver when external `$ref` URIs are used. Return
the referenced schema as a decoded JSON object or boolean schema, or `null`
when the URI is not available:

```dart
final tool = OpenTool.fromJson(
  document,
  schemaReferenceResolver: (uri) => schemaCache[uri],
);
```

Local `$defs` references need no resolver. The OpenTool-local schema registry
remains available through `#/schemas/<name>`.
