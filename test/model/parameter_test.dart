import 'package:opentool_dart/opentool_schema.dart';
import 'package:test/test.dart';

void main() {
  group('Parameter', () {
    test('defaults required to false when omitted from JSON', () {
      final parameter = Parameter.fromJson({
        'name': 'location',
        'schema': {'type': SchemaType.STRING},
      });

      expect(parameter.required, isFalse);
    });
  });
}
