import 'dart:async';

import 'package:dslink/dslink.dart';
import 'package:dslink_zoneminder/zoneminder_nodes.dart';

Future main(List<String> args) async {
  LinkProvider link;

  link = new LinkProvider(args, 'ZoneMinder-',
      command: 'run', profiles: {
        GetMonitors.isType: (String path) => new GetMonitors(path, link),
        ClearMonitors.isType: (String path) => new ClearMonitors(path, link),
        MonitorNode.isType: (String path) => new MonitorNode(path),
        MonitorValue.isType: (String path) => new MonitorValue(path),
        MonitorStreamNode.isType: (String path) => new MonitorStreamNode(path)
      }, autoInitialize: false);

  link.init();
  link.addNode('/${GetMonitors.pathName}', GetMonitors.definition());
  link.addNode('/${ClearMonitors.pathName}', ClearMonitors.definition());
  await link.connect();
}
