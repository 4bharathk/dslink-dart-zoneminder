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

    var events = await client.getEvents(monitor);
    if (events == null) {
      ret[_message] = 'Unable to retrieve events';
    } else if (events.isEmpty) {
      ret[_success] = true;
      ret[_message] = 'There are no events to display';
    } else {
      ret[_success] = true;
      ret[_message] = 'Success!';
      var pPath = parent.path;
      for (var event in events) {
        var nd = provider.getNode('$pPath/${event.id}');
        if (nd != null) continue;
        nd = provider.addNode('$pPath/${event.id}', EventNode.definition(event));
        (nd as EventNode).event = event;
      }
    }

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

class EventNode extends ZmNode {
  static const String isType = 'eventNode';
  static Map<String, dynamic> definition(Event event) => {
    r'$is': isType,
    r'$name': event.name,
    'id': ZmValue.definition('Id', 'number', event.id),
    'monitorId': ZmValue.definition('Monitor Id', 'number', event.monitorId),
    'name': ZmValue.definition('Name', 'string', event.name, write: true),
    'startTime': ZmValue.definition('Start Time', 'string', event.startTime),
    'endTime': ZmValue.definition('end Time', 'string', event.endTime),
    'width': ZmValue.definition('Width', 'number', event.width),
    'height': ZmValue.definition('Height', 'number', event.height),
    'length': ZmValue.definition('Length', 'number', event.length),
    'frameCount': ZmValue.definition('Frame Count', 'number', event.frameCount),
    'alarmFrames':
        ZmValue.definition('Alarm Frames', 'number', event.alarmFrames),
    'Score' : {
      r'$type': 'number',
      r'?value': event.totScore,
      'totScore': ZmValue.definition('Total Score', 'number', event.totScore),
      'avgScore': ZmValue.definition('Average Score', 'number', event.avgScore),
      'maxScore': ZmValue.definition('Max Score', 'number', event.maxScore)
    },
    'notes': ZmValue.definition('Notes', 'string', event.notes, write: true),
    'Frames': {
      // GetFrames.pathName: GetFrames.definition()
    }
  };

  Event event;

  EventNode(String path) : super(path);
}