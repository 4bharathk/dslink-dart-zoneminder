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
    'function': ZmValue.definition('Function', 'string', monitor.function),
    'enabled': ZmValue.definition('Enabled', 'bool', monitor.enabled),
    'linkedMonitors': ZmValue.definition('Linked Monitors', 'string',
        monitor.linkedMonitors),
    'triggers': ZmValue.definition('Triggers', 'string', monitor.triggers),
    'device': ZmValue.definition('Device', 'string', monitor.device),
    'channel': ZmValue.definition('Channel', 'number', monitor.channel),
    'format': ZmValue.definition('Format', 'string', monitor.format),
    'v4multibuffer': ZmValue.definition('v4 MultiBuffer', 'bool',
        monitor.v4LMultiBuffer)
  };

  Monitor monitor;

  MonitorNode(String path) : super(path);
}