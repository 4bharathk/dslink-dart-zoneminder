import 'dart:async';

import 'package:dslink/dslink.dart';

import 'site_node.dart';
import '../../client.dart';
import '../../models.dart';

abstract class ZmParent extends SimpleNode {
  ZmParent(String path) : super(path) {
    serializable = false;
  }

  ZmClient getClient() {
    return getSite()?.client;
  }

  SiteNode getSite() {
    var p = parent;
    while (p is! SiteNode && p != null) {
      p = p.parent;
    }

    return p as SiteNode;
  }
}

abstract class ZmNode extends ZmParent {

  ZmNode(String path) : super(path);

  bool onSetChild(value, ZmValue node);
}

class ZmValue extends SimpleNode {
  static const String isType = 'zmValueNode';
  static Map<String, dynamic> definition(String name, String type, value,
      {String editor, bool write: false}) {
    var ret = {
      r'$is': isType,
      r'$name': name,
      r'$type': type,
      r'?value': value
    };

    if (editor != null) {
      ret[r'$editor'] = editor;
    }
    if (write) {
      ret[r'$writable'] = 'write';
    }

    return ret;
  }

  ZmValue(String path) : super(path) {
    serializable = false;
  }

  ZmNode getParent() {
    var p = parent;
    while (p != null && p is! ZmNode) {
      p = p.parent;
    }
    return p;
  }

  @override
  bool onSetValue(value) => getParent().onSetChild(value, this);
}

abstract class MonitorView {
  Future<Monitor> getMonitor();
  void set monitor(Monitor monitor);
  void update(Monitor monitor);
}
