class Event {
  String id;
  String monitorId;
  String name;
  String startTime;
  String endTime;
  String width;
  String height;
  String length;
  String frames;
  String alarmFrames;
  String totScore;
  String avgScore;
  String maxScore;
  String archived;
  String videoed;
  String uploaded;
  String emailed;
  String messaged;
  String notes;

  Event.fromMap(Map map) {
    id = map['Id'];
    monitorId = map['MonitorId'];
    name = map['Name'];
    startTime = map['StartTime'];
    endTime = map['EndTime'];
    width = map['Width'];
    height = map['Height'];
    length = map['Length'];
    frames = map['Frames'];
    alarmFrames = map['AlarmFrames'];
    totScore = map['TotScore'];
    avgScore = map['AvgScore'];
    maxScore = map['MaxScore'];
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
    json['Frames'] = frames;
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
