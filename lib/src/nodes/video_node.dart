import 'dart:async';

import 'monitor_node.dart';
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
  ZmClient _client;
  String get _strType => getConfig(_feedType);

  @override
  void onCreated() {
    _client = getClient();

    (parent as MonitorNode).getMonitor().then((monitor) {
      _monitor = monitor;

      if (_strType == liveFeed && callbacks.isNotEmpty) {
        startLiveFeed();
        _startLiveFeedNow = false;
      }
    });
  }

  bool _startLiveFeedNow = false;

  void startLiveFeed() {
    if (_monitor == null) {
      _startLiveFeedNow = true;
      return;
    }

    _sub = _client.getMonitorFeed(_monitor).listen((bd) {
      updateValue(bd, force: true);
    });
  }

  void stopLiveFeed() {
    if (_sub != null) {
      _sub.cancel();
      _sub = null;
    }
  }

  @override
  void onSubscribe() {
    if (_strType == liveFeed) {
      startLiveFeed();
    }
  }

  @override
  void onUnsubscribe() {
    if (_strType == liveFeed) {
      stopLiveFeed();
    }
  }

  StreamSubscription _sub;

  bool onSetChild(value, ZmValue node) => true;
}
