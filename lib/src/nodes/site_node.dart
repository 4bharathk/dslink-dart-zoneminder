import 'dart:async';

import 'package:dslink/dslink.dart';

import '../../client.dart';

class AddSiteNode extends SimpleNode {
  static const String isType = 'addSite';
  static const String pathName = 'Add_Site';

  static const String _name = 'name';
  static const String _url = 'url';
  static const String _username = 'username';
  static const String _password = 'password';
  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Add Site',
    r'$invokable' : 'write',
    r'$params' : [
      { 'name': _name, 'type': 'string', 'placeholder': 'Site Name' },
      {
        'name': _url,
        'type': 'string',
        'placeholder': 'http://www.somesite.com:8080/zm'
      },
      { 'name': _username, 'type': 'string', 'placeholder': 'Username' },
      {
        'name': _password,
        'type': 'string',
        'editor': 'password',
        'placeholder': 'Password'
      }
    ],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  AddSiteNode(String path) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, String> params) async {
    var ret = { _success: false, _message : '' };

    var ndName = params[_name]?.trim();
    if (ndName == null || ndName.isEmpty) {
      ret[_message] = 'Name cannot be empty';
      return ret;
    }

    var url = params[_url]?.trim();
    if (url == null || url.isEmpty) {
      ret[_message] = 'URL cannot be empty';
      return ret;
    }
    Uri uri;
    try {
      uri = Uri.parse(url);
    } on Exception {
      ret[_message] = 'Error parsing the provided URL';
      return ret;
    }
    var user = params[_username]?.trim();
    if (user.isEmpty) user = null;
    var pass = params[_password]?.trim();
    if (pass.isEmpty) pass = null;

    var client = new ZmClient(uri, user, pass);
    ret[_success] = await client.authenticate();
    if(ret[_success]) {
      ret[_message] = 'Success!';
      // TODO: Add Site node to tree
    } else {
      ret[_message] = 'Unable to Authenticate to URI';
    }
    return ret;
  }
}