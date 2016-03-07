import 'package:dslink/dslink.dart';
import '../zoneminder_api.dart';

class MonitorNode extends SimpleNode {
  static const String isType = 'monitorNode';
  static Map<String, dynamic> definition(Monitor monitor) => {
    r'$is' : isType,
    r'$$zm_name': monitor.name
  };

  MonitorNode(String path) : super(path);
}