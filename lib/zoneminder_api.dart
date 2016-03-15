import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'src/models/monitor.dart';

export 'src/models/monitor.dart';

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
    var monitors = (decoded['monitors'] as List<Map>).map((Map m) {
      var monitor = new Monitor.fromMap(m['Monitor']);
      return monitor;
    }).toList();

    return monitors;
  }

  Future<Null> updateMonitor(String monitorId, Monitor newValue) async {
    var url = '$instanceUrl$apiBaseUrl/monitors/$monitorId.json';
    var encoded = newValue.toJson();

    encoded.forEach((k, v) => encoded[k] = v.toString());

    var response = await client.put(url, body: encoded);
    var success = response.statusCode - 205 < 0;

    if (!success) {
      throw new Exception(
          "Couldn't update monitor, the API returned ${response.statusCode}");
    }
  }
}

ZoneMinderApi apiInstance = new ZoneMinderApi();
