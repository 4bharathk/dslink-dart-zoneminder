import 'dart:typed_data';
import 'dart:async';
import 'package:collection/collection.dart';

class VideoStreamConsumer {
  static const List<int> zoneMinderFrameDelimiter = const [
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
  ];

  int _offset = -1;

  int findHeaderOffsetForCurrentMonitor(List<int> bytes) {
    var newLineTwice = const [13, 10, 13, 10];
    var consecutiveByteCounter = 0;

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

  Future consume(
      Stream<List<int>> byteStream, void update(ByteData data)) async {
    List<int> bytesToSend = [];

    await for (List<int> bytes in byteStream) {
      if (const ListEquality().equals(bytes, zoneMinderFrameDelimiter)) {
        if (bytesToSend.isEmpty) {
          // I think it can also be the beginning, if so don't send any picture
          continue;
        }

        if (_offset < 0) {
          _offset = findHeaderOffsetForCurrentMonitor(bytesToSend);
        }

        removeHeader(bytesToSend);
        var data = createByteDataFromBytes(bytesToSend);
        update(data);

        bytesToSend = <int>[]; // Reset the buffer
        continue;
      }

      bytesToSend.addAll(bytes);
    }
  }

  ByteData createByteDataFromBytes(List<int> bytesToSend) {
    var buffer = new Uint8List.fromList(bytesToSend).buffer;
    var data = new ByteData.view(buffer);
    return data;
  }

  void removeHeader(List<int> bytes) {
    bytes.removeRange(0, _offset);
  }
}
