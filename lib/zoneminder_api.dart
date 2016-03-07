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
}

class Monitor {
  String id;
  String name;
  String serverId;
  String type;
  String function;
  // TODO: Rest

  Monitor.fromMap(Map m) {
    id = m['Id'];
    name = m['Name'];
    serverId = m['ServerId'];
    type = m['Type'];
    function = m['Function'];
  }
}
