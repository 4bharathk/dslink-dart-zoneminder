import 'package:dslink/dslink.dart';
import 'monitor_value_node.dart';
import '../zoneminder_api.dart';
import 'dart:convert';

class MonitorNode extends SimpleNode {
  static const String isType = 'monitorNode';

  static Map<String, dynamic> definition(Monitor monitor) {
    return {
      r'$is': isType,
      r'$instanceUrl':
          MonitorValue.definition(monitor.instanceUrl, writable: false),
      'Id': MonitorValue.definition(monitor.id, writable: false),
      'Name': MonitorValue.definition(monitor.name),
      'ServerId': MonitorValue.definition(monitor.serverId),
      'Type': MonitorValue.definition(monitor.type,
          type: enumFrom(Monitor.sourceTypes)),
      'Function': MonitorValue.definition(monitor.function),
      r'$monitor': MonitorValue.definition(JSON.encode(monitor),
          writable: false, type: 'map')
    };
  }

  Monitor monitor;

  MonitorNode(String path) : super(path);

  @override
  void onCreated() {
    apiInstance.instanceUrl = (getConfig(r'$instanceUrl') as Map)['?value'];

    var monitorJsonNode = getConfig(r'$monitor');
    var decodedJson = JSON.decode(monitorJsonNode['?value']);
    monitor = new Monitor.fromMap(decodedJson);
  }
}

enumFrom(List<String> values) => 'enum[${values.join(',')}]';
