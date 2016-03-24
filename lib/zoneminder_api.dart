import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'src/models/monitor.dart';
import 'src/models/event.dart';

export 'src/models/monitor.dart';
export 'src/utils.dart';

class ZoneMinderApi {
  static const String apiBaseUrl = '/zm/api';
  static const String streamPath = '/zm/cgi-bin/zms';

  BaseClient client;
  Uri instanceUrl;

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

  Future<ByteStream> getMonitorStream(String monitorId) async {
    var queryUri = instanceUrl.replace(
        path: streamPath,
        queryParameters: <String, String>{'monitor': monitorId});

    var streamedResponse = await client.send(new Request('GET', queryUri));

    return streamedResponse.stream;
  }

  Future<List<Event>> getMonitorEvents(String monitorId) async {
    var url = Uri.parse(
        '$instanceUrl$apiBaseUrl/events/index/MonitorId:$monitorId.json');

    var response = await client.get(url);

    var body = response.body;
    var decoded = JSON.decode(body);

    var numberOfPages =
        (decoded['pagination'] as Map<String, dynamic>)['pageCount'];

    var events = (decoded['events'] as List<Map>).map((Map m) {
      var event = new Event.fromMap(m['Event']);
      return event;
    }).toList();

    for (int i = 2; i <= numberOfPages; ++i) {
      var newQueryUri = url.replace(queryParameters: {'page': i.toString()});

      var response = await client.get(newQueryUri);

      var body = response.body;
      var decoded = JSON.decode(body);

      var moreEvents = (decoded['events'] as List<Map>).map((Map m) {
        var event = new Event.fromMap(m['Event']);
        return event;
      });

      events.addAll(moreEvents);
    }

    return events;
  }

  Future<ByteStream> getEventStream(String eventId) async {
    var queryUri = instanceUrl.replace(
        path: streamPath,
        queryParameters: <String, String>{'source': 'event', 'event': eventId});

    var streamedResponse = await client.send(new Request('GET', queryUri));

    return streamedResponse.stream;
  }
}

ZoneMinderApi apiInstance = new ZoneMinderApi();
