import 'dart:async';

import 'package:dslink/dslink.dart';
import 'package:dslink/utils.dart' show logger;
import 'package:dslink/nodes.dart' show NodeNamer;

import 'monitor_node.dart';
import 'common.dart';
import '../../client.dart';
import '../../models.dart' show Host;

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

  final LinkProvider link;

  AddSiteNode(String path, this.link) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, String> params) async {
    var ret = { _success: false, _message : '' };

    var ndName = params[_name]?.trim();
    if (ndName == null || ndName.isEmpty) {
      ret[_message] = 'Name cannot be empty';
      return ret;
    }
    ndName = NodeNamer.createName(ndName);

    var pp = parent.path;
    var tmpNd = provider.getNode('$pp/$ndName');
    if (tmpNd != null) {
      ret[_message] = 'A site by that name already exists.';
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
      provider.addNode('$pp/$ndName', SiteNode.definition(uri, user, pass));
      link.save();
    } else {
      ret[_message] = 'Unable to Authenticate to URI';
    }
    return ret;
  }
}

class EditSiteNode extends SimpleNode {
  static const String isType = 'editSiteNode';
  static const String pathName = 'Edit_Site';

  static const String _url = 'url';
  static const String _username = 'username';
  static const String _password = 'password';
  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition(Uri uri, String username,
      String password) => {
    r'$is' : isType,
    r'$name' : 'Edit Site',
    r'$invokable' : 'write',
    r'$params' : [
      {
        'name': _url,
        'type': 'string',
        'default': uri.toString()
      },
      { 'name': _username, 'type': 'string', 'default': username },
      {
        'name': _password,
        'type': 'string',
        'editor': 'password',
        'default': password
      }
    ],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  LinkProvider _link;

  EditSiteNode(String path, this._link) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: false, _message: ''};

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
    if (ret[_success]) {
      (parent as SiteNode).update(uri, user, pass);
      configs[r'$params'] = [
        {
          'name': _url,
          'type': 'string',
          'default': uri.toString()
        },
        { 'name': _username, 'type': 'string', 'default': user},
        {
          'name': _password,
          'type': 'string',
          'editor': 'password',
          'default': pass
        }
      ];
      ret[_message] = 'Success!';
      _link.save();
    } else {
      ret[_message] = 'Unable to Authenticate to URI';
    }

    return ret;
  }

}

class RemoveSiteNode extends SimpleNode {
  static const String isType = 'removeSiteNode';
  static const String pathName = 'Remove_Site';

  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Remove Site',
    r'$invokable' : 'write',
    r'$params' : [],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  LinkProvider _link;

  RemoveSiteNode(String path, this._link) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: true, _message: 'Success!' };

    provider.removeNode(parent.path);
    _link.save();
    return ret;
  }
}

class SiteNode extends SimpleNode {
  static const String isType = 'siteNode';
  static const String _url = r'$$zm_url';
  static const String _user = r'$$zm_user';
  static const String _pass = r'$$zm_pass';
  static Map<String, dynamic> definition(Uri uri, String user, String pass) => {
    r'$is' : isType,
    _url: uri.toString(),
    _user: user,
    _pass: pass,
    'monitors': {},
    EditSiteNode.pathName: EditSiteNode.definition(uri, user, pass),
    RemoveSiteNode.pathName: RemoveSiteNode.definition(),
  };

  static const Duration _duration = const Duration(seconds: 10);

  SiteNode(String path) : super(path);
  ZmClient client;
  Timer timer;

  @override
  onCreated() async {
    Uri uri;
    var url = getConfig(_url);
    var user = getConfig(_user);
    var pass = getConfig(_pass);
    try {
      uri = Uri.parse(url);
    } catch (e) {
      logger.warning('Error loading Node: $url', e);
    }

    client = new ZmClient(uri, user, pass);
    var auth = await client.authenticate();
    if (!auth) {
      logger.warning('Unable to authenticate');
      return;
    }

    var monitors = await client.listMonitors();
    if (monitors == null) return;
    for (var monitor in monitors) {
      var nd = provider.addNode('$path/monitors/${monitor.id}',
          MonitorNode.definition(monitor));
      (nd as MonitorNode).monitor = monitor;
    }

    client.getHostDetails().then((host) {
      updateHost(host);
      if (timer != null) return;

      timer = new Timer.periodic(_duration, (_) async {
        updateHost(await client.getHostDetails());
      });
    });
  }

  @override
  void onRemoving() {
    client?.close();
  }

  void update(Uri uri, String username, String password) {
    var tmpClient = new ZmClient(uri, username, password);
    if (client != tmpClient) {
      client.close();
      client = tmpClient;
    }

    configs[_url] = uri.toString();
    configs[_user] = username;
    configs[_pass] = password;
  }

  void updateHost(Host host) {
    void getOrUpdate(String path, Map node) {
      var nd = provider.getNode(path);
      if (nd != null) {
        nd.updateValue(node['?value']);
        return;
      }

      provider.addNode(path, node);
    }

    getOrUpdate('$path/running',
        ZmValue.definition('Running', 'bool', host.isRunning));
    getOrUpdate('$path/cpuOne',
        ZmValue.definition('CPU Avg (1 Minute)', 'number', host.cpuOne));
    getOrUpdate('$path/cpuFive',
        ZmValue.definition('CPU Avg (5 Minute)', 'number', host.cpuFive));
    getOrUpdate('$path/cpuFifteen',
        ZmValue.definition('CPU Avg (15 Minute)', 'number', host.cpuFifteen));

    host.diskUsage.forEach((String monitor, num disk) {
      var nm = NodeNamer.createName(monitor);
      getOrUpdate('$path/$nm',
          ZmValue.definition('$monitor Disk Space (GB)', 'number', disk));
    });
  }

}