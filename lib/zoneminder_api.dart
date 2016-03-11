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
  String enabled;
  String linkedMonitors;
  String triggers;
  String device;
  String channel; //  "0",
  String format; //  "255",
  bool v4LMultiBuffer; //  false,
  String v4LCapturesPerFrame; //  "1",
  String protocol; //  "http",
  String method; //  "simple",
  String host; //  "admin:password@192.168.1.132",
  String port; //  "80",
  String subPath; //  "",
  String path; //  "\/video\/mjpg.cgi",
  String options; //  "",
  String user; //  "",
  String pass; //  "",
  String width; //  "640",
  String height; //  "360",
  String colours; //  "4",
  String palette; //  "0",
  String orientation; //  "0",
  String deinterlacing; //  "0",
  bool rTSPDescribe; //  false,
  String brightness; //  "-1",
  String contrast; //  "-1",
  String hue; //  "-1",
  String colour; //  "-1",
  String eventPrefix; //  "Event-",
  String labelFormat; //  "%N - %d\/%m\/%y %H:%M:%S",
  String labelX; //  "0",
  String labelY; //  "0",
  String labelSize; //  "1",
  String imageBufferCount; //  "50",
  String warmupCount; //  "25",
  String preEventCount; //  "25",
  String postEventCount; //  "25",
  String streamReplayBuffer; //  "1000",
  String alarmFrameCount; //  "1",
  String sectionLength; //  "600",
  String frameSkip; //  "0",
  String motionFrameSkip; //  "0",
  String analysisFPS; //  "0.00",
  String analysisUpdateDelay; //  "0",
  String maxFPS; //  "0.00",
  String alarmMaxFPS; //  "0.00",
  String fPSReportInterval; //  "1000",
  String refBlendPerc; //  "6",
  String alarmRefBlendPerc; //  "6",
  String controllable; //  "0",
  String controlId; //  "0",
  dynamic controlDevice; //  null,
  dynamic controlAddress; //  null,
  dynamic autoStopTimeout; //  null,
  String trackMotion; //  "0",
  String trackDelay; //  "0",
  String returnLocation; //  "-1",
  String returnDelay; //  "0",
  String defaultView; //  "Events",
  String defaultRate; //  "100",
  String defaultScale; //  "100",
  String signalCheckColour; //  "#0000c0",
  String webColour; //  "red",
  bool exif; //  false,
  String sequence; //  "1"

  String instanceUrl;
  // TODO: Rest

  Monitor.fromMap(Map m) {
    id = m['Id'];
    name = m['Name'];
    serverId = m['ServerId'];
    type = m['Type'];
    function = m['Function'];
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
}

ZoneMinderApi apiInstance = new ZoneMinderApi();
