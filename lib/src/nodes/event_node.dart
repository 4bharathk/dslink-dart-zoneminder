import 'dart:async';

import 'common.dart';
import '../../models.dart';
import 'video_node.dart';

class GetEventsNode extends ZmParent {
  static const String isType = 'getEventsNode';
  static const String pathName = 'Get_Events';

  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Load Events',
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

      var ndList = parent.children.values.toList();
      for (var nd in ndList) {
        if (nd == null || nd is! EventNode) continue;
        provider.removeNode((nd as EventNode).path);
      }

      for (var event in events) {
        var nd = provider.addNode('$pPath/${event.id}', EventNode.definition(event));
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

class DeleteEvent extends ZmParent {
  static const String isType = 'deleteEventNode';
  static const String pathName = 'Delete_Event';

  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Delete Event',
    r'$invokable' : 'write',
    r'$params' : [],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  DeleteEvent(String path) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: false, _message : '' };

    var event = (parent as EventNode)._event;
    var client = getClient();
    ret[_success] = await client.deleteEvent(event);
    ret[_message] = (ret[_success] ? 'Success!': 'Unable to delete event');
    if (ret[_success]) {
      provider.removeNode(parent.path);
    }

    return ret;
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
    'streamUrl': ZmValue.definition('Stream URL', 'string', event.stream.toString()),
    'stream': VideoNode.definition(VideoNode.eventFeed),
    'notes': ZmValue.definition('Notes', 'string', event.notes, write: true),
    'Frames': {
       GetFrames.pathName: GetFrames.definition(event.id)
    },
    DeleteEvent.pathName: DeleteEvent.definition()
  };

  Event _event;
  Completer<Event> _eventComp;
  Future<Event> getEvent() => _eventComp.future;

  void set event(Event e) {
    _event = e;
    _eventComp.complete(_event);
  }

  EventNode(String path) : super(path) {
    _eventComp = new Completer<Event>();
  }

  bool onSetChild(value, ZmValue node) {
    var client = getClient();
    var oldValue = node.value;
    if (node.name == 'name') {
      client.setEventDetails(_event, 'Name', value).then((success) {
        if (success) return;
        node.updateValue(oldValue);
        this.displayName = oldValue;
        _event.name = oldValue;
      });
      _event.name = value;
      this.displayName = value;
      return false;
    } else if (node.name == 'notes') {
      client.setEventDetails(_event, 'Notes', value).then((success) {
        if (success) return;
        node.updateValue(oldValue);
        _event.notes = oldValue;
      });
      _event.notes = value;
      return false;
    }
    return true;
  }

}

class GetFrames extends ZmParent {
  static const String isType = 'getFrames';
  static const String pathName = 'Get_Frames';

  static const String _success = 'success';
  static const String _message = 'message';
  static const String _eventId = r'$$eventId';

  static Map<String, dynamic> definition(int id) => {
    r'$is' : isType,
    _eventId : id,
    r'$name' : 'Get Frames',
    r'$invokable' : 'write',
    r'$params' : [],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  int _eId;

  GetFrames(String path) : super(path);

  @override
  void onCreated() {
    _eId = getConfig(_eventId);
  }

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: false, _message : '' };

    if (_eId == null) {
      ret[_message] = 'Unable to retrieve event Id';
      return ret;
    }

    var client = getClient();
    var result = await client.getEvent(_eId);
    if (result == null) {
      ret[_message] = 'Unable to retrieve event Id: $_eId';
    } else {
      ret[_success] = true;
      ret[_message] = 'Success!';

      var pPath = parent.path;
      for (var frame in result.frames) {
        provider.addNode('$pPath/${frame.id}', FrameNode.definition(frame));
      }
    }

    return ret;
  }
}

class FrameNode extends ZmNode {
  static const String isType = 'frameNode';
  static Map<String, dynamic> definition(Frame frame) => {
    r'$is': isType,
    r'$name': 'Frame ${frame.frameId}',
    'id': ZmValue.definition('Id', 'number', frame.id),
    'eventId': ZmValue.definition('Event Id', 'number', frame.eventId),
    'frameId': ZmValue.definition('Frame Id', 'number', frame.frameId),
    'type': ZmValue.definition('Type', 'string', frame.type),
    'timeStamp': ZmValue.definition('TimeStamp', 'string', frame.timestamp),
    'delta': ZmValue.definition('Delta', 'number', frame.delta),
    'score': ZmValue.definition('Score', 'number', frame.score),
    'uri': ZmValue.definition('Url', 'string', frame.imageUri.toString())
  };

  FrameNode(String path): super(path);

  bool onSetChild(value, ZmValue node) {
    return true;
  }
}
