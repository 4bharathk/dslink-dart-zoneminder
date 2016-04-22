class Event {
  int id;
  int monitorId;
  String name;
  String startTime;
  String endTime;
  int width;
  int height;
  num length;
  int frameCount;
  int alarmFrames;
  int totScore;
  num avgScore;
  num maxScore;
  String archived;
  String videoed;
  String uploaded;
  String emailed;
  String messaged;
  String notes;

  Uri stream;

  Event.fromMap(Map<String, String> map) {
    id = int.parse(map['Id']);
    monitorId = int.parse(map['MonitorId']);
    name = map['Name'];
    startTime = map['StartTime'];
    endTime = map['EndTime'];
    width = int.parse(map['Width']);
    height = int.parse(map['Height']);
    length = num.parse(map['Length']);
    frameCount = int.parse(map['Frames']);
    alarmFrames = int.parse(map['AlarmFrames']);
    totScore = int.parse(map['TotScore']);
    avgScore = num.parse(map['AvgScore']);
    maxScore = num.parse(map['MaxScore']);
    archived = map['Archived'];
    videoed = map['Videoed'];
    uploaded = map['Uploaded'];
    emailed = map['Emailed'];
    messaged = map['Messages'];
    notes = map['Notes'];
  }

  Map toJson() {
    var json = <String, String>{};

    json['Id'] = id;
    json['MonitorId'] = monitorId;
    json['Name'] = name;
    json['StartTime'] = startTime;
    json['EndTime'] = endTime;
    json['Width'] = width;
    json['Height'] = height;
    json['Length'] = length;
    json['Frames'] = frameCount;
    json['AlarmFrames'] = alarmFrames;
    json['TotScore'] = totScore;
    json['AvgScore'] = avgScore;
    json['MaxScore'] = maxScore;
    json['Archived'] = archived;
    json['Videoed'] = videoed;
    json['Uploaded'] = uploaded;
    json['Emailed'] = emailed;
    json['Messages'] = messaged;
    json['Notes'] = notes;

    return json;
  }
}

class EventDetails extends Event {
  final Uri rootUri;
  String basePath;
  List<Frame> frames;

  EventDetails.fromJson(Map<String, dynamic> map, this.rootUri) :
        super.fromMap(map['Event']) {
    basePath = 'zm/${map['Event']['BasePath']}';
    frames = new List<Frame>();
    for (var mp in map['Frame']) {
      frames.add(new Frame.fromJson(mp, rootUri, basePath));
    }
  }
}

class Frame {
  int id;
  int eventId;
  int frameId;
  String type;
  String timestamp;
  num delta;
  int score;
  Uri imageUri;

  bool get _isAlarm => type == 'Alarm';

  Frame.fromJson(Map<String, String> map, Uri rootUri, String basePath) {
    id = int.parse(map['Id']);
    eventId = int.parse(map['EventId']);
    frameId = int.parse(map['FrameId']);
    type = map['Type'];
    timestamp = map['TimeStamp'];
    delta = num.parse(map['Delta']);
    score = int.parse(map['Score']);

    var imgNum = '$frameId'.padLeft(5, '0');
    var imgType = (_isAlarm ? 'analyse' : 'capture');
    var imgPath = '${basePath}$imgNum-$imgType.jpg';
    imageUri = rootUri.replace(path: imgPath);
  }
}
