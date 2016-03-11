import 'package:dslink/dslink.dart';
import 'monitor_value_node.dart';
import '../zoneminder_api.dart';
import 'dart:convert';

class MonitorNode extends SimpleNode {
  static const String isType = 'monitorNode';

  static Map<String, dynamic> definition(Monitor monitor) => {
        r'$is': isType,
        r'$instanceUrl':
            MonitorValue.definition(monitor.instanceUrl, writable: false),
        'id': MonitorValue.definition(monitor.id, writable: false),
        'name': MonitorValue.definition(monitor.name),
        'serverId': MonitorValue.definition(monitor.serverId),
        'function': MonitorValue.definition(monitor.function),
        r'$monitor': MonitorValue.definition(JSON.encode(monitor),
            writable: false, type: 'map')
      };

  Monitor _monitor;

  void set monitor(Monitor newValue) {}

  Monitor get monitor => _monitor;

  MonitorNode(String path) : super(path);

  @override
  void onCreated() {
    apiInstance.instanceUrl = (getConfig(r'$instanceUrl') as Map)['?value'];

    var monitorJsonNode = getConfig(r'$monitor');
    var decodedJson = JSON.decode(monitorJsonNode['?value']);
    _monitor = new Monitor.fromMap(decodedJson);
  }
}
