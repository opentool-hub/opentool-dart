import 'package:snowflaker/snowflaker.dart';
import 'package:uuid/uuid.dart';

final snowflaker = Snowflaker(workerId: 1, datacenterId: 1);

String uniqueId({bool shorter = true}) {
  if(shorter) {
    return snowflaker.nextId().toString();
  }
  return Uuid().v4();

}

void main() {
  String id = uniqueId(shorter: false);
  print(id);
}