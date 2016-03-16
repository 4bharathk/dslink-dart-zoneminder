import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

import 'package:dslink/dslink.dart';

class MonitorStreamNode extends SimpleNode {
  MonitorStreamNode(String path) : super(path);

  static const String isType = 'monitorStream';

  static Map<String, dynamic> definition(String monitorId) {
    var definition = {r'$is': isType, r'$type': 'dynamic'};

    return definition;
  }

  int _offset = -1;

  int findHeaderOffsetForCurrentMonitor(List<int> bytes) {
    var newLineTwice = [13, 10, 13, 10];
    int consecutiveByteCounter = 0;

    for (int i = 0; i < bytes.length; ++i) {
      if (bytes[i] == newLineTwice[consecutiveByteCounter]) {
        consecutiveByteCounter++;

        if (consecutiveByteCounter == 4) {
          _offset = i + 1;
          return _offset;
        }
      } else {
        consecutiveByteCounter = 0;
      }
    }

    throw new Exception(
        "Couldn't find header, and therefore couldn't calculate header offset");
  }

  @override
  Future onCreated() async {
    var uri =
        new Uri.http('localhost:1337', '/zm/cgi-bin/zms', {'monitor': '2'});
    var client = new http.Client();
    var streamedResponse = await client.send(new http.Request('GET', uri));

    List<int> bytesToSend = [];

    await for (List<int> bytes in streamedResponse.stream) {
      if (const ListEquality().equals(bytes, [
        45,
        45,
        90,
        111,
        110,
        101,
        77,
        105,
        110,
        100,
        101,
        114,
        70,
        114,
        97,
        109,
        101,
        13,
        10
      ])) {
        // This is the "End of frame" marker ^
        if (bytesToSend.isEmpty) {
          // I think it can also be the beginning, if so don't send any picture
          continue;
        }

        if (_offset < 0) {
          _offset = findHeaderOffsetForCurrentMonitor(bytesToSend);
        }

        bytesToSend.removeRange(0, _offset);

        var buffer = new Uint8List.fromList(bytesToSend).buffer;

        var data = new ByteData.view(buffer);

        updateValue(data);

        bytesToSend = []; // Reset the buffer
        continue;
      }

      bytesToSend.addAll(bytes);
    }
  }
}
