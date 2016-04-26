class Host {
  bool isRunning;
  num cpuOne;
  num cpuFive;
  num cpuFifteen;
  Map<String, num> diskUsage = <String, num>{};

  Host();
  void parseRunning(Map map) {
    isRunning = map['result'] == 1;
  }

  void parseLoad(Map map) {
    cpuOne = map['load'][0];
    cpuFive = map['load'][1];
    cpuFifteen = map['load'][2];
  }

  void parseDisk(Map map) {
    if (map['usage'] == null) return;
    (map['usage'] as Map<String, Map>).forEach((key, value) {
      diskUsage[key] = value['space'];
    });
  }
}