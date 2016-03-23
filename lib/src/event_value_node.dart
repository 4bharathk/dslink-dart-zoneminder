import 'package:dslink/dslink.dart';
import 'models/event.dart';

class EventValueNode extends SimpleNode {
  EventValueNode(String path) : super(path);

  static const String isType = 'eventValueNode';

  static Map<String, dynamic> definition(Event value) {
    var jsonMap = value.toJson();
    var definition = {r'$is': isType, '?value': jsonMap};

    jsonMap.forEach((key, value) {
      definition[key] = valueDefinition(value);
    });

    return definition;
  }

  static Map<String, dynamic> valueDefinition(String value) {
    return {r'$is': isType, r'$type': 'string', '?value': value};
  }
}
