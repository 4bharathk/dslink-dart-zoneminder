import 'package:test/test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:dslink_zoneminder/zoneminder_api.dart';
import 'dart:io';

main() {
  group('getMonitors', () {
    var client = new MockClient((Request r) {
      if (r.url.path == '/zm/api/monitors.json') {
        var sampleData = new File('2-monitors.json').readAsStringSync();
        return new Response(sampleData, 200,
            headers: {'content-type': 'application/json'});
      }
    });

    var api = new ZoneMinderApi();
    api.instanceUrl = 'http://localhost:8080';
    api.client = client;

    test('should return correct monitors', () async {
      var result = await api.fetchAllMonitors();

      expect(result.length, 2);
      var monitor1 = result[0];
      expect(monitor1.id, '2');
      expect(monitor1.name, 'Monitor-2');
      expect(monitor1.type, 'Remote');
      expect(monitor1.function, 'Monitor');

      var monitor2 = result[1];
      expect(monitor2.id, '3');
      expect(monitor2.name, 'Monitor-3');
      expect(monitor2.type, 'Local');
      expect(monitor2.function, 'Monitor');
    });
  });
}
