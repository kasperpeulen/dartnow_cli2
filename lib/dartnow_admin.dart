library dartnow.dartnow_admin;

import 'dart:async';
import 'package:github/server.dart';
import 'dart:convert';
import 'package:dartnow/dart_snippet.dart';
import 'package:http/http.dart';
import 'package:dartnow/dartnow.dart';
import 'package:dartnow/dartnow_user.dart';

class DartNowAdmin extends DartNow {

  String get secret {
    if(config['secret'] == null) throw 'You don\'t have admin access';
   return config['secret'];
  }
  Map<String, String> newIds;

  DartNowAdmin() : super();

  Future<Map<String, String>> fetchNew() async {
    Response response = await get(
        'https://dartnow.firebaseio.com/new.json');
    newIds = JSON.decode(response.body);
    return newIds;
  }

  updateNew() async {
    Map<String,String> newIds = await fetchNew();
    if (newIds == null || newIds.isEmpty) {
      print('No new ids to process.');
      return;
    }
    for (String key in newIds.keys) {
      await update(newIds[key]);
      await deleteNew(newIds[key]);
    }
  }

  update(String id) async {
    Gist gist = await getGist(id);
    DartSnippet snippet = new DartSnippet.fromGist(gist);
    await patch(
        'https://dartnow.firebaseio.com/gists.json?auth=$secret',
        body: JSON.encode({snippet.id: snippet.toJson()}));
    print('Snippet added to https://dartnow.firebaseio.com/gists/${id}');
    print('You can view the snippet at http://dartnow.org');

    await updateUser(gist.owner.login);
  }

  updateUser(String username) async {
    DartNow dartnow = new DartNow();
    User user = await dartnow.gitHub.users.getUser(username);
    DartNowUser dartnowUser = new DartNowUser(user);
    await dartnowUser.onReady;
    await dartnowUser.updateToFirebase();
  }

  deleteGist(String id) async {
    await delete('https://dartnow.firebaseio.com/gists/$id.json?auth=$secret');
    print('$id deleted from gists.json');
  }

  deleteNew(String id) async {
    if (newIds == null) {
      newIds = await fetchNew();
    }
    while (newIds.keys.any((key) => newIds[key] == id)) {
      String key = newIds.keys.firstWhere((key) => newIds[key] == id);
      await delete('https://dartnow.firebaseio.com/new/$key.json');
      print('$id deleted from new.json');
      newIds[key] = null;
    }
  }

}