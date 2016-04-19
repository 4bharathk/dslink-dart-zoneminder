import 'package:dslink/dslink.dart';

import 'site_node.dart';
import '../../client.dart';

abstract class ZmNode extends SimpleNode {

  ZmNode(String path) : super(path) {
    serializable = false;
  }

  ZmClient getClient() {
    var p = parent;
    while (p is! SiteNode && p != null) {
      p = p.parent;
    }

    return (p as SiteNode)?.client;
  }
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
}