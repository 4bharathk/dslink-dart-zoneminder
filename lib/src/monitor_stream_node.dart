import 'dart:async';
import 'video_stream_consumer.dart';

import 'package:dslink/dslink.dart';
import '../zoneminder_api.dart';
import 'monitor_node.dart';

class MonitorStreamNode extends SimpleNode {
  MonitorStreamNode(String path) : super(path);

  static const String isType = 'monitorStream';

  static Map<String, dynamic> definition(int monitorId) {
    var definition = {r'$is': isType, r'$type': 'dynamic'};

    return definition;
  }

  @override
  Future onCreated() async {
    var monitorId = (parent as MonitorNode).monitor.id;
    var monitorStream = await apiInstance.getMonitorStream(monitorId.toString());

    var streamConsumer = new VideoStreamConsumer();

    streamConsumer.consume(monitorStream, updateValue);
  }
}
