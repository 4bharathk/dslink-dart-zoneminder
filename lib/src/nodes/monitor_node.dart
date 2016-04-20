import 'dart:async';

import 'common.dart';
import '../../models.dart';

class MonitorNode extends ZmNode {
  static const String isType = 'monitorNode';
  static Map<String, dynamic> definition(Monitor monitor) => {
    r'$is': isType,
    r'$name': monitor.name,
    'id': ZmValue.definition('Id', 'number', monitor.id),
    'name': ZmValue.definition('Name', 'string', monitor.name, write: true),
    'serverId': ZmValue.definition('Server Id', 'number', monitor.serverId),
    'type': ZmValue.definition('Type', 'string', monitor.type),
    'function': ZmValue.definition('Function', Monitor.functionsEnum,
        monitor.function, write: true),
    'enabled': ZmValue.definition('Enabled', 'bool', monitor.enabled),
    'linkedMonitors': ZmValue.definition('Linked Monitors', 'string',
        monitor.linkedMonitors),
    'triggers': ZmValue.definition('Triggers', 'string', monitor.triggers),
    'device': ZmValue.definition('Device', 'string', monitor.device),
    'channel': ZmValue.definition('Channel', 'number', monitor.channel),
    'format': ZmValue.definition('Format', 'string', monitor.format),
    'v4multibuffer': ZmValue.definition('v4 MultiBuffer', 'bool',
        monitor.v4LMultiBuffer),
    'liveUri': ZmValue.definition('Live URL', 'string',
        monitor.stream.toString()),
    RefreshMonitorNode.pathName: RefreshMonitorNode.definition()
  };

  Monitor monitor;

  MonitorNode(String path) : super(path);

  void update(Monitor monitor) {
    provider.updateValue('$path/id', monitor.id);
    this.displayName = monitor.name;
    provider.updateValue('$path/name', monitor.name);
    provider.updateValue('$path/serverId', monitor.serverId);
    provider.updateValue('$path/type', monitor.type);
    provider.updateValue('$path/function', monitor.function);
    provider.updateValue('$path/enabled', monitor.enabled);
    provider.updateValue('$path/linkedMonitors', monitor.linkedMonitors);
    provider.updateValue('$path/triggers', monitor.triggers);
    provider.updateValue('$path/device', monitor.device);
    provider.updateValue('$path/channel', monitor.channel);
    provider.updateValue('$path/format', monitor.format);
    provider.updateValue('$path/v4multibuffer', monitor.v4LMultiBuffer);
    provider.updateValue('$path/liveUri', monitor.stream.toString());
  }
}

class RefreshMonitorNode extends ZmNode {
  static const String isType = 'refreshMonitorNode';
  static const String pathName = 'Refresh_Monitor';

  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Refresh Monitor',
    r'$invokable' : 'write',
    r'$params' : [],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  RefreshMonitorNode(String path) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: false, _message : '' };

    var monitor = (parent as MonitorNode).monitor;
    var client = getClient();

    var result = await client?.getMonitor(monitor.id);
    if (result != null) {
      ret[_success] = true;
      ret[_message] = 'Success!';
      (parent as MonitorNode).update(result);
    } else {
      ret[_message] = 'Unable to refresh monitor.';
    }

    return ret;
  }
}