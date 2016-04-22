import 'dart:async';

import 'common.dart';
import '../../models.dart';

class GetEventsNode extends ZmNode {
  static const String isType = 'getEventsNode';
  static const String pathName = 'Get_Events';

  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Get Events',
    r'$invokable' : 'write',
    r'$params' : [],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  GetEventsNode(String path) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: false, _message : '' };

    var client = getClient();
    var monitor = await getMonitor();
    return ret;
  }

  Future<Monitor> getMonitor() async {
    var p = parent;
    while (p is! MonitorView && p != null) {
      p = p.parent;
    }

    if (p == null) return null;
    return await (p as MonitorView).getMonitor();
  }
}