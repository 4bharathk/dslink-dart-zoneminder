class Monitor {
  int id;
  String name;
  int serverId;
  String type;
  String function;
  bool enabled;
  String linkedMonitors;
  String triggers;
  String device;
  int channel; //  "0",
  String format; //  "255",
  bool v4LMultiBuffer; //  false,
  int v4LCapturesPerFrame; //  "1",
  String protocol; //  "http",
  String method; //  "simple",
  String host; //  "admin:password@192.168.1.132",
  int port; //  "80",
  String subPath; //  "",
  String path; //  "\/video\/mjpg.cgi",
  String options; //  "",
  String user; //  "",
  String pass; //  "",
  int width; //  "640",
  int height; //  "360",
  int colours; //  "4",
  String palette; //  "0",
  String orientation; //  "0",
  String deinterlacing; //  "0",
  bool rTSPDescribe; //  false,
  int brightness; //  "-1",
  int contrast; //  "-1",
  int hue; //  "-1",
  String colour; //  "-1",
  String eventPrefix; //  "Event-",
  String labelFormat; //  "%N - %d\/%m\/%y %H:%M:%S",
  int labelX; //  "0",
  int labelY; //  "0",
  int labelSize; //  "1",
  int imageBufferCount; //  "50",
  int warmupCount; //  "25",
  int preEventCount; //  "25",
  num postEventCount; //  "25",
  num streamReplayBuffer; //  "1000",
  num alarmFrameCount; //  "1",
  num sectionLength; //  "600",
  num frameSkip; //  "0",
  num motionFrameSkip; //  "0",
  num analysisFPS; //  "0.00",
  num analysisUpdateDelay; //  "0",
  num maxFPS; //  "0.00",
  num alarmMaxFPS; //  "0.00",
  num fPSReportInterval; //  "1000",
  num refBlendPerc; //  "6",
  num alarmRefBlendPerc; //  "6",
  num controllable; //  "0",
  num controlId; //  "0",
  dynamic controlDevice; //  null,
  dynamic controlAddress; //  null,
  dynamic autoStopTimeout; //  null,
  num trackMotion; //  "0",
  num trackDelay; //  "0",
  String returnLocation; //  "-1",
  String returnDelay; //  "0",
  String defaultView; //  "Events",
  num defaultRate; //  "100",
  num defaultScale; //  "100",
  String signalCheckColour; //  "#0000c0",
  String webColour; //  "red",
  bool exif; //  false,
  String sequence; //  "1"

  String instanceUrl;
  Uri stream;

  Map content;

  Monitor();

  Monitor.fromMap(Map<String, String> m) {
    id = int.parse(m['Id']);
    name = m['Name'];
    serverId = int.parse(m['ServerId']);
    type = m['Type'];
    function = m['Function'];
    enabled = m['Enabled'] == "1";
    linkedMonitors = m['LinkedMonitors'];
    triggers = m['Triggers'];
    device = m['Device'];
    channel = int.parse(m['Channel']);
    format = m['Format'];
    v4LMultiBuffer = m['V4LMultiBuffer'] == "true";
    v4LCapturesPerFrame = int.parse(m['V4LCapturesPerFrame']);
    protocol = m['Protocol'];
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'Id': id,
      'Name': name,
      'ServerId': serverId,
      'Type': type,
      'Function': function,
      'Enabled': enabled,
      'LinkedMonitors': linkedMonitors,
      'Triggers': triggers,
      'Device': device,
      'Channel': channel,
      'Format': format,
      'V4LMultiBuffer': v4LMultiBuffer,
      'V4LCapturesPerFrame': v4LCapturesPerFrame,
      'Protocol': protocol,
    };

    return json;
  }

  static String get sourcesEnum => 'enum[${sourceTypes.join(',')}]';
  static const List<String> sourceTypes = const [
    'Local',
    'Remote',
    'File',
    'Ffmpeg',
    'cURL',
    'Libvlc'
  ];

  static String get functionsEnum => 'enum[${functions.join(',')}]';
  static const List<String> functions = const [
    'None',
    'Monitor',
    'Modect',
    'Record',
    'Mocord',
    'Nodect'
  ];

  static const List<String> booleanOneZero = const ['1', '0'];
}
