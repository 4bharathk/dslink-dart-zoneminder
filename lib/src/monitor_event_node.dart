import 'package:dslink/dslink.dart';
import 'models/monitor.dart';
import 'models/event.dart';
import 'event_value_node.dart';
import '../zoneminder_api.dart';
import 'dart:async';

class MonitorEventsNode extends SimpleNode {
  MonitorEventsNode(String path, this._link) : super(path);

  static const String isType = 'monitorEventsNode';

  static Map<String, dynamic> definition(Monitor monitor) {
    return {r'$is': isType, r'$monitorId': monitor.id, 'type': 'list'};
  }

  final LinkProvider _link;

  @override
  Future<Null> onCreated() async {
    var monitorId = getConfig(r'$monitorId');
    var events = await apiInstance.getMonitorEvents(monitorId);

    if (events.isEmpty) {
      _link.removeNode(path);
    }

    for (var event in events) {
      var newNode = _link.addNode(
              '$path/event_${event.id}', EventValueNode.definition(event))
          as SimpleNode;
      newNode.displayName = 'Event ${event.id}';
    }
  }
}
