import 'dart:async';
import 'package:dslink/dslink.dart';
import 'monitor_node.dart';

class ClearMonitors extends SimpleNode {
  static const String isType = 'clearMonitorsNode';
  static const String pathName = 'Clear_Monitors';

  static Map<String, dynamic> definition() => {
        r'$is': isType,
        r'$name': 'clear monitors',
        r'$invokable': 'write',
        r'$columns': [
          {'name': 'success', 'type': 'bool', 'default': false},
          {'name': 'message', 'type': 'string', 'default': ''}
        ]
      };

  final LinkProvider _link;

  ClearMonitors(String path, this._link) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = {'success': false, 'message': ''};

    var childrenKeys = provider.getNode('/').children.keys.toList();
    childrenKeys.forEach((String key) {
      var pathToDelete = '/$key';
      var nodeToDelete = provider.getNode(pathToDelete);
      if (nodeToDelete is MonitorNode) {
        provider.removeNode(pathToDelete);
      }
    });

    _link.save();

    ret['success'] = true;
    ret['message'] = 'Success';
    return ret;
  }
}
