import 'dart:async';

import 'monitor_node.dart';
import 'event_node.dart';
import 'common.dart';
import '../../models.dart';
import '../../client.dart';

class VideoNode extends ZmNode {
  static const String liveFeed = 'liveFeed';
  static const String eventFeed = 'eventFeed';
  static const String isType = 'videoNode';

  static const String _feedType = r'$$feedType';
  static Map<String, dynamic> definition(String type) => {
    r'$is': isType,
    _feedType: type,
    r'$name' : 'Video Stream',
    r'$type' : 'binary',
    r'?value' : null,
  };

  VideoNode(String path) : super(path);

  Monitor _monitor;
  Event _event;
  ZmClient _client;
  String get _strType => getConfig(_feedType);

  @override
  void onCreated() {
    _client = getClient();

    if (_strType == liveFeed) {
      (parent as MonitorNode).getMonitor().then((monitor) {
        _monitor = monitor;

        if (callbacks.isNotEmpty) {
          startLiveFeed();
        }
      });
    } else if (_strType == eventFeed) {
      (parent as EventNode).getEvent().then((event) {
        _event = event;

        if (callbacks.isNotEmpty) {
          startLiveFeed();
        }
      });
    }
  }

  void startLiveFeed() {
    print('$_strType');
    if (_strType == liveFeed) {
      if (_monitor == null) return;
      _sub = _client.getMonitorFeed(_monitor).listen(_listener);
    } else if (_strType == eventFeed) {
      print('Event: $_event');
      if (_event == null) return;
      _sub = _client.getEventFeed(_event).listen(_listener);
    }
  }

  void _listener(bd) {
    updateValue(bd, force: true);
  }

  void stopLiveFeed() {
    _sub?.cancel();
    _sub = null;
  }

  @override
  void onSubscribe() {
    if (_strType == liveFeed || _strType == eventFeed) {
      startLiveFeed();
    }
  }

  @override
  void onUnsubscribe() {
    if (_strType == liveFeed || _strType == eventFeed) {
      stopLiveFeed();
    }
  }

  StreamSubscription _sub;

  bool onSetChild(value, ZmValue node) => true;
}
