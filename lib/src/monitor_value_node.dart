import 'package:dslink/dslink.dart';
import 'monitor_node.dart';
import '../zoneminder_api.dart';

class MonitorValueNode extends SimpleNode {
  MonitorValueNode(String path) : super(path);

  static const String isType = 'monitorValueNode';

  static Map<String, dynamic> definition(dynamic value,
      {bool writable: false, String type: 'string', String editor: null}) {
    var definition = {r'$is': isType, r'$type': type, '?value': value,};

    if (writable) {
      definition[r'$writable'] = 'write';
    }

    if (editor == 'int') {
      definition[r'$type'] = 'number';
      definition[r'$editor'] = 'int';
    }

    return definition;
  }

  @override
  Response setValue(Object value, Responder responder, Response response,
      [int maxPermission = Permission.CONFIG]) {
    var currentMonitor = (parent as MonitorNode).monitor;

    var monitorJson = currentMonitor.toJson();
    monitorJson[name] = value;
    var updatedMonitor = new Monitor.fromMap(monitorJson);

    apiInstance.updateMonitor(currentMonitor.id, updatedMonitor).then((_) {
      (parent as MonitorNode).monitor = updatedMonitor;
      updateValue(value);
      parent.displayName = updatedMonitor.name;
      response.close();
    }, onError: (e) {
      print(e);
      response.close(new DSError("Update error",
          msg: "Couldn't update the given monitor"));
    });

    return response;
  }
}
