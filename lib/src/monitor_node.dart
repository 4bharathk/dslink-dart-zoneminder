import 'package:dslink/dslink.dart';
import 'monitor_value_node.dart';
import 'monitor_stream_node.dart';
import '../zoneminder_api.dart';
import 'dart:convert';

class MonitorNode extends SimpleNode {
  MonitorNode(String path) : super(path);

  static const String isType = 'monitorNode';

  static Map<String, dynamic> definition(Monitor monitor) {
    return {
      r'$is': isType,
      r'$instanceUrl': MonitorValue.definition(monitor.instanceUrl),
      'Id': MonitorValue.definition(monitor.id),
      'Name': MonitorValue.definition(monitor.name, writable: true),
      'ServerId': MonitorValue.definition(monitor.serverId),
      'Type': MonitorValue.definition(monitor.type,
          type: enumFrom(Monitor.sourceTypes), writable: true),
      'Function': MonitorValue.definition(monitor.function,
          type: enumFrom(Monitor.functions), writable: true),
      'Enabled': MonitorValue.definition(monitor.enabled,
          type: enumFrom(Monitor.booleanOneZero), writable: true),
      'LinkedMonitors': MonitorValue.definition(monitor.linkedMonitors),
      'Triggers': MonitorValue.definition(monitor.triggers),
      'Device': MonitorValue.definition(monitor.device),
      'Channel': MonitorValue.definition(monitor.channel, editor: 'int'),
      'Format': MonitorValue.definition(monitor.format),
      'V4LMultiBuffer':
          MonitorValue.definition(monitor.v4LMultiBuffer, type: 'bool'),
      'Stream': MonitorStreamNode.definition(monitor.id),
      r'$monitor': MonitorValue.definition(JSON.encode(monitor),
          writable: false, type: 'map')
    };
  }

  Monitor monitor;

  @override
  void onCreated() {
    apiInstance.instanceUrl = (getConfig(r'$instanceUrl') as Map)['?value'];

    var monitorJsonNode = getConfig(r'$monitor') as Map;
    var decodedJson = JSON.decode(monitorJsonNode['?value']);
    monitor = new Monitor.fromMap(decodedJson);
  }
}

String enumFrom(List<String> values) => 'enum[${values.join(',')}]';
