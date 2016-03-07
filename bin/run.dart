import 'dart:async';

import 'package:dslink/dslink.dart';
import 'package:dslink_zoneminder/zoneminder_nodes.dart';

Future main(List<String> args) async {
  LinkProvider link;

  link = new LinkProvider(args, 'ZoneMinder-',
      command: 'run', profiles: {
        GetMonitors.isType: (String path) => new GetMonitors(path, link)
      }, autoInitialize: false);

  link.init();
  link.addNode('/${GetMonitors.pathName}', GetMonitors.definition());
  await link.connect();
}
