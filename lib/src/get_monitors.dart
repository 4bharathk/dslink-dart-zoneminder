import 'package:dslink/nodes.dart';
import 'package:dslink/dslink.dart';
import 'package:quiver/strings.dart';

import '../zoneminder_api.dart';

import 'monitor_node.dart';

import 'dart:async';

class GetMonitors extends SimpleNode {
  static const String isType = 'getMonitorsNode';
  static const String pathName = 'Get_Monitors';

  static Map<String, dynamic> definition() => {
        r'$is': isType,
        r'$name': 'get monitors',
        r'$invokable': 'write',
        r'$params': [
          {
            'name': 'Instance URL',
            'type': 'string',
            'placeholder': 'http://zoneminderaddress:port'
          }
        ],
        r'$columns': [
          {'name': 'success', 'type': 'bool', 'default': false},
          {'name': 'message', 'type': 'string', 'default': ''}
        ]
      };

  final LinkProvider _link;
  final ZoneMinderApi _api;

  GetMonitors(String path, this._link)
      : super(path),
        _api = new ZoneMinderApi();

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = {'success': false, 'message': ''};

    var instanceUrl = params[GetMonitorsParams.instanceUrl];

    if (isEmpty(instanceUrl)) {
      ret['message'] = 'Instance URL is required';
      return ret;
    }

    _api.instanceUrl = instanceUrl;

    var monitors = await _api.fetchAllMonitors();

    for (var monitor in monitors) {
      var name = NodeNamer.createName(monitor.name);
      provider.addNode('/$name', MonitorNode.definition(monitor));
    }

    _link.save();

    ret['success'] = true;
    ret['message'] = 'Success';
    return ret;
  }
}

class GetMonitorsParams {
  static const String instanceUrl = 'Instance URL';
}
