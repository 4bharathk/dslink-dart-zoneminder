import 'package:dslink_zoneminder/client.dart';

main() async {
  var uri = Uri.parse('http://192.168.99.100:32770');
  var client = new ZmClient(uri, 'api', 'testApi');
  var auth = await client.authenticate();
  print(auth);
  if (auth) {
    var list = await client.listMonitors();
    var id = list[0].id;
    print('$id: ${list[0].name}');
    var mon = await client.getMonitor(id);
    print('${mon.id}: ${mon.name}');
  }
}