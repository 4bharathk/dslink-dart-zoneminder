import 'package:dslink_zoneminder/client.dart';

main() async {
  var client = new ZmClient('http://192.168.99.100', 32769, 'api', 'testApi');
  var auth = await client.authenticate();
  print(auth);
  if (auth) {
    print(await client.listMonitors());
  }
}