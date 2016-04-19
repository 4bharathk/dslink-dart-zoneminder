import 'dart:async';
import 'dart:convert' show UTF8, JSON;
import 'dart:io';

import 'package:dslink/utils.dart' show logger;

import 'models.dart';

class ZmClient {
  static Map<String, ZmClient> _cache = <String, ZmClient>{};

  HttpClient _client;
  String _username;
  String _password;
  Uri _rootUri;
  bool _authenticated = false;

  List<Cookie> _cookies;

  factory ZmClient(Uri uri, String username, String password) {
    var tmp = _cache.putIfAbsent('$username@${uri.host}:${uri.port}',
        () => new ZmClient._(uri, username, password));
    if (tmp._password != password) {
      tmp._password = password;
      tmp._authenticated = false;
      tmp._cookies = null;
    }
    return tmp;
  }

  ZmClient._(Uri uri, String username, String password) {
    _rootUri = uri.replace(path: '', query: '', fragment: '');
    _username = username;
    _password = password;
    _client = new HttpClient();
  }

  Future<bool> authenticate() async {
    var params = {
      'action': 'login',
      'view': 'console'
    };

    if (_username != null && _password != null) {
      params['username'] = _username;
      params['password'] = _password;
    }

    var uri = _rootUri.replace(path: PathHelper.auth, queryParameters: params);
    HttpClientResponse resp;
    String body;
    try {
      var req = await _client.getUrl(uri);
      resp = await req.close();
      if (resp.statusCode == HttpStatus.OK) {
        if (resp.cookies.isNotEmpty) {
          _cookies = resp.cookies;
        }
        body = await UTF8.decodeStream(resp);
      }
    } catch (e) {
      return _authenticated = false;
    }
    _authenticated = (resp.statusCode == HttpStatus.OK &&
        !body.contains("currentView = 'login'"));
    if (!_authenticated) {
      logger.warning('Unable to authenticate to server');
    }
    return _authenticated;
  }

  /// Retrieve a list of all connected Monitors on the serve.
  /// Returns a List of [Monitor]s.
  Future<List<Monitor>> listMonitors() async {
    var resp = await get(PathHelper.monitors);
    if (resp == null) return null;
    List<Monitor> list;
    if (resp.body['monitors'] != null && resp.body['monitors'].isNotEmpty) {
      list = new List<Monitor>();
      for(var map in resp.body['monitors']) {
        list.add(new Monitor.fromMap(map['Monitor']));
      }
    }
    return list;
  }

  /// Retrieves details of a specific monitor identified by the [monitor]
  /// parameter. Returns a [Future]<[Monitor]> or `null` on error.
  Future<Monitor> getMonitor(int monitor) async {
    var resp = await get(PathHelper.monitor(monitor));
    if (resp == null) return null;
    Monitor ret;
    if (resp.body['monitor'] != null && resp.body['monitor'].containsKey('Monitor')) {
      ret = new Monitor.fromMap(resp.body['monitor']['Monitor']);
    }

    return ret;
  }

  Future<ClientResponse> get(String path, [Map queryParams]) async {
    var uri = _generateUri(path, queryParams);
    return _sendRequest(RequestType.get, uri);
  }

  Future<ClientResponse> post(String path, [Map queryParams]) async {
    var uri = _generateUri(path, queryParams);
    return _sendRequest(RequestType.post, uri);
  }

  Future<ClientResponse> put(String path, [Map queryParams]) async {
    var uri = _generateUri(path, queryParams);
    return _sendRequest(RequestType.put, uri);
  }

  Future<ClientResponse> delete(String path, [Map queryParams]) async {
    var uri = _generateUri(path, queryParams);
    return _sendRequest(RequestType.delete, uri);
  }

  void close() {
    _client.close();
    _cache.remove('$_username@${_rootUri.host}:${_rootUri.port}');
  }

  Uri _generateUri(String path, Map queryParams) {
    Uri uri;
    if (queryParams == null) {
      uri = _rootUri.replace(path: path);
    } else {
      uri = _rootUri.replace(path: path, queryParameters: queryParams);
    }
    return uri;
  }

  Future<ClientResponse> _sendRequest(RequestType type, Uri uri) async {
    HttpClientRequest req;
    HttpClientResponse resp;
    ClientResponse ret;

    try {
      switch (type) {
        case RequestType.get:
          req = await _client.getUrl(uri);
          break;
        case RequestType.put:
          req = await _client.putUrl(uri);
          break;
        case RequestType.post:
          req = await _client.postUrl(uri);
          break;
        case RequestType.delete:
          req = await _client.deleteUrl(uri);
          break;
      }

      if (_cookies != null && _cookies.isNotEmpty) {
        req.cookies.addAll(_cookies);
      }
      resp = await req.close();
      var body = JSON.decode(await UTF8.decodeStream(resp));
      ret = new ClientResponse(resp.statusCode, body);
    } catch (e, s) {
      logger.warning('Unable to complete request:', e, s);
      ret = null;
    }

    return ret;
  }

}

enum RequestType { get, put, post, delete }

class ClientResponse {
  Map<String, dynamic> body;
  int status;
  ClientResponse(this.status, this.body);
}

abstract class PathHelper {
  static final String root = '/zm';
  static final String api = '$root/api';
  static final String auth = '$root/index.php';

  static final String monitors = '$api/monitors.json';
  static String monitor(int id) => '$api/monitors/$id.json';
}