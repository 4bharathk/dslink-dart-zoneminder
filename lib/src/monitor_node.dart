import 'package:dslink/dslink.dart';
import 'monitor_value_node.dart';
import 'monitor_stream_node.dart';
import 'monitor_event_node.dart';
import '../zoneminder_api.dart';
import 'dart:convert';
import 'utils.dart';

class MonitorNode extends SimpleNode {
  MonitorNode(String path) : super(path);

  static const String isType = 'monitorNode';

  static Map<String, dynamic> definition(Monitor monitor) {
    return {
      r'$is': isType,
      r'$instanceUrl': MonitorValueNode.definition(monitor.instanceUrl),
      'Id': MonitorValueNode.definition(monitor.id),
      'Name': MonitorValueNode.definition(monitor.name, writable: true),
      'ServerId': MonitorValueNode.definition(monitor.serverId),
      'Type': MonitorValueNode.definition(monitor.type,
          type: enumFrom(Monitor.sourceTypes), writable: true),
      'Function': MonitorValueNode.definition(monitor.function,
          type: enumFrom(Monitor.functions), writable: true),
      'Enabled': MonitorValueNode.definition(monitor.enabled,
          type: enumFrom(Monitor.booleanOneZero), writable: true),
      'LinkedMonitors': MonitorValueNode.definition(monitor.linkedMonitors),
      'Triggers': MonitorValueNode.definition(monitor.triggers),
      'Device': MonitorValueNode.definition(monitor.device),
      'Channel': MonitorValueNode.definition(monitor.channel, editor: 'int'),
      'Format': MonitorValueNode.definition(monitor.format),
      'V4LMultiBuffer':
          MonitorValueNode.definition(monitor.v4LMultiBuffer, type: 'bool'),
      'Stream': MonitorStreamNode.definition(monitor.id),
      'Events': MonitorEventsNode.definition(monitor),
      r'$monitor': MonitorValueNode.definition(JSON.encode(monitor),
          writable: false, type: 'map')
    };
  }

  Monitor monitor;

  @override
  void onCreated() {
    var url = (getConfig(r'$instanceUrl') as Map)['?value'];
    apiInstance.instanceUrl = parseAddress(url);

    var monitorJsonNode = getConfig(r'$monitor') as Map;
    var decodedJson = JSON.decode(monitorJsonNode['?value']);
    monitor = new Monitor.fromMap(decodedJson);
  }
}
