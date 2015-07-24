library dartnow.user;

import 'package:github/server.dart';
import 'package:dartnow/dartnow_admin.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'dart:convert';


class DartNowUser {

  User user;

  DartNowAdmin admin = new DartNowAdmin();

  String get secret => admin.secret;

  List<String> gists;

  Future onReady;

  DartNowUser(this.user) {
    onReady = new Future(() async {
      gists = await _gists;
    });
  }

  String get avatarUrl => user.avatarUrl;
  String get name => user.name;
  int get id => user.id;
  String get email => user.email;
  String get username => user.login;

  Map toJson() => {
    'name': name,
    'avatarUrl': avatarUrl,
    'id': id,
    'username': username,
    'gists': gists,
    'gistCount': gists.length
  };

  updateToFirebase() async {
    await patch(
        'https://dartnow.firebaseio.com/users.json?auth=$secret',
        body: JSON.encode({username: toJson()}));
    print('User added to https://dartnow.firebaseio.com/users/${username}');
    print('User gist count is ${gists.length}');
  }

  Future<List<String>> get _gists async {
    Response response = await get(
        'https://dartnow.firebaseio.com/gists.json');
    Map<String, Map> json = JSON.decode(response.body);
    List<String> ids = json.keys.toList();
    ids.retainWhere((String id) {
      Map gist = json[id];
      if (gist['author'] == username) {
        return true;
      }
    });
    return ids;
  }
}