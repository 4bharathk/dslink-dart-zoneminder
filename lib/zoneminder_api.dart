import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';

class ZoneMinderApi {
  static const String apiBaseUrl = '/zm/api';

  BaseClient client;
  String instanceUrl;

  ZoneMinderApi() {
    client = new Client();
  }

  Future<List<Monitor>> fetchAllMonitors() async {
    var url = '$instanceUrl$apiBaseUrl/monitors.json';
    var response = await client.get(url);

    var body = response.body;
    var decoded = JSON.decode(body);
    var monitors = (decoded['monitors'] as List<Map>)
        .map((Map m) => new Monitor.fromMap(m['Monitor']))
        .toList();

    return monitors;
  }

  Future<Null> updateMonitor(String monitorId, Monitor newValue) async {
    var url = '$instanceUrl$apiBaseUrl/monitors/$monitorId.json';
    var encoded = newValue.toJson();
    await client.put(url, body: encoded);
  }
}

class Monitor {
  String id;
  String name;
  String serverId;
  String type;
  String function;

  String instanceUrl;
  // TODO: Rest

  Monitor.fromMap(Map m) {
    id = m['Id'];
    name = m['Name'];
    serverId = m['ServerId'];
    type = m['Type'];
    function = m['Function'];
  }

  factory Monitor.clone(Monitor monitor) {
    return new Monitor.fromMap(JSON.decode(JSON.encode(monitor)));
  }

  Map toJson() {
    var json = <String, dynamic>{
      'Id': id,
      'Name': name,
      'ServerId': serverId,
      'Type': type,
      'Function': function
    };

    return json;
  }

  void update(String fieldName, dynamic newValue) {
    switch (fieldName) {
      case 'name':
        name = newValue;
        break;
      case 'serverId':
        serverId = newValue;
        break;
      case 'type':
        type = newValue;
        break;
      case 'function':
        function = newValue;
        break;
      default:
        throw new Exception('Not yet implemented');
    }
  }
}

ZoneMinderApi apiInstance = new ZoneMinderApi();
