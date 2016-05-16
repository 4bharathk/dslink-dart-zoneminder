import 'package:dslink_zoneminder/client.dart';
import 'package:dslink_zoneminder/models.dart';

main() async {
  var uri = Uri.parse('http://192.168.99.100:32768');
  var client = new ZmClient(uri, 'api', 'testApi');
  var auth = await client.authenticate();
  print(auth);
  Monitor mon;
  if (auth) {
    var list = await client.listMonitors();
    var id = list[0].id;
    print('$id: ${list[0].name}');
    mon = await client.getMonitor(id);
    print('${mon.id}: ${mon.name}');
  }

  var err = await client.deleteEvent(null);
}
