import 'package:dslink/dslink.dart';
import 'dart:async';
import 'models/event.dart';
import 'video_stream_consumer.dart';
import '../zoneminder_api.dart';

class EventStreamNode extends SimpleNode {
  EventStreamNode(path) : super(path);

  static const String isType = 'eventStreamNode';

  static Map<String, dynamic> definition(Event event) {
    return {
      r'$is': isType,
      r'$type': 'dynamic',
      r'$event': event.toJson(),
      '?value': 'Video feed not yet fetched'
    };
  }

  Event event;
  Timer streamLoopTimer;

  @override
  void onCreated() {
    var eventJson = getConfig(r'$event') as Map;
    var event = new Event.fromMap(eventJson);

    this.event = event;
  }

  @override
  Future onSubscribe() async {
    var videoLength = num.parse(event.length).ceil();

    var videoStreamConsumer = new VideoStreamConsumer();

    streamLoopTimer = new Timer.periodic(new Duration(seconds: videoLength + 5),
        (Timer t) async {
      var byteStream = await apiInstance.getEventStream(event.id);
      videoStreamConsumer.consume(byteStream, updateValue);
    });
  }

  @override
  void onUnsubscribe() {
    streamLoopTimer.cancel();
  }
}
