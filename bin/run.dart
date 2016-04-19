import 'dart:async';

import 'package:dslink/dslink.dart';

import 'package:dslink_zoneminder/nodes.dart';

Future main(List<String> args) async {
  LinkProvider link;

  link = new LinkProvider(args, 'ZoneMinder-', command: 'run', profiles: {
        AddSiteNode.isType: (String path) => new AddSiteNode(path, link),
        EditSiteNode.isType: (String path) => new EditSiteNode(path, link),
        RemoveSiteNode.isType: (String path) => new RemoveSiteNode(path, link),
        SiteNode.isType: (String path) => new SiteNode(path)
      }, defaultNodes: {
        'Sites' : {
          AddSiteNode.pathName: AddSiteNode.definition()
        }
  }, autoInitialize: false, encodePrettyJson: true);

//  link = new LinkProvider(args, 'ZoneMinder-',
//      command: 'run',
//      profiles: {
//        GetMonitors.isType: (String path) => new GetMonitors(path, link),
//        ClearMonitors.isType: (String path) => new ClearMonitors(path, link),
//        MonitorNode.isType: (String path) => new MonitorNode(path),
//        MonitorValueNode.isType: (String path) => new MonitorValueNode(path),
//        MonitorStreamNode.isType: (String path) => new MonitorStreamNode(path),
//        MonitorEventsNode.isType: (String path) =>
//            new MonitorEventsNode(path, link),
//        EventValueNode.isType: (String path) => new EventValueNode(path),
//        EventStreamNode.isType: (String path) => new EventStreamNode(path)
//      },
//      autoInitialize: false);
//
//  link.init();
//  link.addNode('/${GetMonitors.pathName}', GetMonitors.definition());
//  link.addNode('/${ClearMonitors.pathName}', ClearMonitors.definition());
//  link.addNode('/Sites/${AddSiteNode.pathName}', AddSiteNode.definition());
  link.init();
  await link.connect();
}
