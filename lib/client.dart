import 'dart:async';
import 'dart:convert' show UTF8, JSON;
import 'dart:io';

import 'package:dslink/utils.dart' show logger;

class ZmClient {
  static Map<String, ZmClient> _cache = <String, ZmClient>{};

  HttpClient _client;
  String _username;
  String _password;
  Uri _rootUri;
  bool _authenticated = false;

  List<Cookie> _cookies;

  factory ZmClient(String url, int port, String username, String password) =>
    _cache['$url:$port'] ??= new ZmClient._(url, port, username, password);

  ZmClient._(String url, int port, String username, String password) {
    _rootUri = Uri.parse('$url:$port');
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

    var resp = await get(PathHelper.auth, params);
    _authenticated = (resp.status == HttpStatus.OK &&
        !resp.body.contains("currentView = 'login'")) ;
    return _authenticated;
  }

  Future<Map> listMonitors() async {
    var resp = await get(PathHelper.monitors);
    return JSON.decode(resp.body);
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
      if (resp.statusCode == HttpStatus.OK && resp.cookies.isNotEmpty) {
        _cookies = resp.cookies;
      }
      var body = await UTF8.decodeStream(resp);
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
  String body;
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