import 'package:dslink/dslink.dart';
import 'package:dslink/nodes.dart';

import '../zoneminder_api.dart';
import 'dart:convert';
import 'dart:async';

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

  MonitorNode(String path) : super(path);

  Monitor _monitor;

  void set monitor(Monitor newValue) {}

  Monitor get monitor => _monitor;

  @override
  void onCreated() {
    apiInstance.instanceUrl = (getConfig(r'$instanceUrl') as Map)['?value'];

    var monitorJsonNode = getConfig(r'$monitor');
    var decodedJson = JSON.decode(monitorJsonNode['?value']);
    _monitor = new Monitor.fromMap(decodedJson);
  }
}

class MonitorValue extends SimpleNode {
  static const String isType = 'monitorValue';

  static Map<String, dynamic> definition(dynamic value,
      {bool writable: true, String type: 'string'}) {
    var definition = {r'$is': isType, r'$type': type, '?value': value,};

    if (writable) {
      definition[r'$writable'] = 'write';
    }

    return definition;
  }

  @override
  Response setValue(Object value, Responder responder, Response response,
      [int maxPermission = Permission.CONFIG]) {
    var currentMonitor = (parent as MonitorNode).monitor;

    var copyOfMonitor = new Monitor.clone(currentMonitor);
    copyOfMonitor.update(name, value);

    apiInstance.updateMonitor(currentMonitor.id, copyOfMonitor).then((_) {
      (parent as MonitorNode).monitor = copyOfMonitor;
      updateValue(value);
      parent.displayName = copyOfMonitor.name;
      response.close();
    }, onError: (e) {
      print(e);
      response.close(new DSError("Update error",
          msg: "Couldn't update the given monitor"));
    });

    return response;
  }

  MonitorValue(String path) : super(path);
}
