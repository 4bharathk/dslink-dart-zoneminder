import 'package:dslink/nodes.dart';
import 'package:dslink/dslink.dart';
import 'package:quiver/strings.dart';

import '../zoneminder_api.dart';
import 'uri_parser.dart';

import 'monitor_node.dart';

import 'dart:async';

class GetMonitors extends SimpleNode {
  GetMonitors(String path, this._link) : super(path);

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

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = {'success': false, 'message': ''};

    var instanceUrl = params[GetMonitorsParams.instanceUrl];

    if (isEmpty(instanceUrl)) {
      ret['message'] = 'Instance URL is required';
      return ret;
    }

    apiInstance.instanceUrl = parseAddress(instanceUrl);

    List<Monitor> monitors;

    try {
      monitors = await apiInstance.fetchAllMonitors();
    } on FormatException {
      ret['success'] = false;
      ret['message'] = "Couldn't deserialize content from Zoneminder API.";
      return ret;
    }

    for (var monitor in monitors) {
      monitor.instanceUrl = instanceUrl;
      var name = NodeNamer.createName(monitor.id);
      var node = provider.addNode('/$name', MonitorNode.definition(monitor));
      node.displayName = monitor.name;
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
