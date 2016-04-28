import 'dart:async';

import 'common.dart';
//import 'video_node.dart';
import 'event_node.dart';
import '../../models.dart';

abstract class MonitorNames {
  static const _name = 'name';
  static const _function = 'function';
  static const _enabled = 'enabled';
  static const _v4MultiBuffer = 'v4multibuffer';
  static const Map<String, String> server = const {
    _name: 'Name',
    _function: 'Function',
    _enabled: 'Enabled',
    _v4MultiBuffer: 'V4LMultiBuffer'
  };
}

class MonitorNode extends ZmNode implements MonitorView {
  static const String isType = 'monitorNode';
  static Map<String, dynamic> definition(Monitor monitor) => {
    r'$is': isType,
    r'$name': monitor.name,
    'id': ZmValue.definition('Id', 'number', monitor.id),
    MonitorNames._name:
        ZmValue.definition('Name', 'string', monitor.name, write: true),
    'serverId': ZmValue.definition('Server Id', 'number', monitor.serverId),
    'type': ZmValue.definition('Type', 'string', monitor.type),
    MonitorNames._function:
        ZmValue.definition('Function', Monitor.functionsEnum, monitor.function,
            write: true),
    MonitorNames._enabled:
        ZmValue.definition('Enabled', 'bool', monitor.enabled, write: true),
    'linkedMonitors': ZmValue.definition('Linked Monitors', 'string',
        monitor.linkedMonitors),
    'triggers': ZmValue.definition('Triggers', 'string', monitor.triggers),
    'device': ZmValue.definition('Device', 'string', monitor.device),
    'channel': ZmValue.definition('Channel', 'number', monitor.channel),
    'format': ZmValue.definition('Format', 'string', monitor.format),
    MonitorNames._v4MultiBuffer: ZmValue.definition('v4L MultiBuffer', 'bool',
        monitor.v4LMultiBuffer, write: true),
    'liveUri': ZmValue.definition('Live URL', 'string',
        monitor.stream.toString()),
    //'liveFeed': VideoNode.definition(VideoNode.liveFeed),
    'events': {
      GetEventsNode.pathName: GetEventsNode.definition()
    },
    RefreshMonitorNode.pathName: RefreshMonitorNode.definition()
  };

  Future<Monitor> getMonitor() async {
    return _monitor ?? _monitorComp.future;
  }
  void set monitor(Monitor monitor) {
    _monitor = monitor;
    _monitorComp.complete(_monitor);
  }
  Completer<Monitor> _monitorComp;
  Monitor _monitor;

  MonitorNode(String path) : super(path) {
    _monitorComp = new Completer<Monitor>();
  }

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

  bool onSetChild(value, ZmValue node) {
    var client = getClient();
    var oldVal = node.value;

    Future<bool> fut;
    switch (node.name) {
      case MonitorNames._name:
        fut = client.setMonitorDetails(_monitor,
                MonitorNames.server[node.name], value);
        displayName = name;
        break;
      case MonitorNames._enabled:
        var tmp = (value ? "1" : "0");
        fut = client.setMonitorDetails(_monitor,
                MonitorNames.server[node.name], tmp);
        break;
      case MonitorNames._v4MultiBuffer:
      case MonitorNames._function:
        fut = client.setMonitorDetails(_monitor,
                  MonitorNames.server[node.name], value);
        break;
      default: return true;
    }

    fut.then((success) {
      if (success) return;
      node.updateValue(oldVal);
      if (node.name == MonitorNames._name) displayName = oldVal;
    });
    return false;
  }
}

class RefreshMonitorNode extends ZmParent {
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

    var monitor = await (parent as MonitorNode).getMonitor();
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