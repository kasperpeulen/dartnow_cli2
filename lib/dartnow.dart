library dartnow.dartnow;

import 'dart:async';
import 'dart:io';
import 'package:github/server.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:dartnow/dart_snippet.dart';
import 'package:http/http.dart';
import 'package:prompt/prompt.dart';
import 'package:dartnow/pubspec.dart';
import 'package:dartnow/dartnow_admin.dart';

class DartNow {

  Map config;
  Map get _config {
    File file = new File('dartnow.json');
    if (! file.existsSync()) {
      throw 'Please run "dartnow init" first.';
    }
    return JSON.decode(file.readAsStringSync());
  }

  GitHub gitHub;
  GitHub get _gitHub => createGitHubClient(auth: new Authentication.withToken(token));

  String username;
  String get _username => _config['username'];

  String get token => _config['token'];


  Directory playgroundDir;
  Directory get _playgroundDir {
    Directory dir = new Directory('playground');
    if (! dir.existsSync()) {
      throw 'Please run "dartnow init" first.';
    }
    return dir;
  }


  DartNow() {
    config = _config;
    username = _username;
    gitHub = _gitHub;
    playgroundDir = _playgroundDir;
  }

  static addConfig() {
    Map config = {};
    config['username'] = askSync(new Question('Github Username'));

    config['token'] = askSync(new Question('''
To get read and write access to your github gists, you need to specify a github token. \n
See this article, how to create such a token:
https://help.github.com/articles/creating-an-access-token-for-command-line-use/\n
Token:''', secret: true));
    String json = new JsonEncoder.withIndent('  ').convert(config);
    new File('dartnow.json').writeAsStringSync(json);
  }

  static createPlayground() {
    _createPlayground();
    print('"playground" dir has been created.');
  }

  static resetPlayground() {
    new Directory('playground').deleteSync(recursive:true);
    _createPlayground();
    print('"playground" dir has been reset.');
  }


  /// Default value of [inputDir] is `new Directory('playground')`
  Future<Gist> createGist([Directory inputDir]) async {
    if (inputDir == null) inputDir = _playgroundDir;
    Gist gist = await _gitHub.gists.createGist(getFiles(inputDir), public: true);
    print('Gist created at ${gist.htmlUrl}');
    return gist;
  }

  add(String id) async {
    await updateGist(id);
    await addToFireBase(id);

    if (config['secret'] != null) {
      DartNowAdmin secret = new DartNowAdmin();
      await secret.updateNew();
    }
  }

  push(String dir) async {
    Process.runSync('git', ['pull'], workingDirectory: dir);
    Process.runSync('git', ['add', '-u'], workingDirectory: dir);
    Process.runSync('git', ['commit', '-m \'.\''], workingDirectory: dir);
    Process.runSync('git', ['push'], workingDirectory: dir);

    var p = new PubSpec.fromString(new File('$dir/pubspec.yaml').readAsStringSync());
    String id = p.id;

    await add(id);

    Process.runSync('git', ['pull'], workingDirectory: dir);

  }

  Future<Gist> cloneGist(String id) async {
    Gist gist = await getGist(id);
    DartSnippet snippet = new DartSnippet.fromGist(gist);
    String outputDir = 'my_gists/${snippet.name}';
    // clone the gist to the outputdir
    Process.runSync('git', ['clone', snippet.gistUrl, outputDir]);
    Process.runSync('pub', ['get'], workingDirectory: outputDir);
    print('Gist cloned in $outputDir');
    return gist;
  }


  /// Update a gist.
  ///
  /// Updates the readme, adds the homepage to the pubspec and updates
  /// the gist description.
  Future<Gist> updateGist(String id) async {
    Gist gist = await getGist(id);
    DartSnippet snippet = new DartSnippet.fromGist(gist);
    await snippet.updateGist(gitHub);
    return gist;
  }


  addToFireBase(String id) async {
    await post(
        'https://dartnow.firebaseio.com/new.json',
        body: JSON.encode(id));
    print('$id added to https://dartnow.firebaseio.com/new.json');
  }

  Future<Gist> getGist(String id) async => await _gitHub.gists.getGist(id);

  /// Gets all files, assuming a flat gist structure. Remove all directories and
  /// ignored files (.packages, pubspec.lock).
  Map<String, String> getFiles(Directory inputDir) {
    List<FileSystemEntity> allFiles = inputDir.listSync();
    allFiles.removeWhere((file) => file is Directory);
    allFiles.removeWhere((file) => file.path.contains('pubspec.lock'));
    allFiles.removeWhere((file) => file.path.contains('.packages'));

    Map<String, String> files = new Map.fromIterable(allFiles,
        key: (File file) => path.basename(file.path),
        value: (File file) => file.readAsStringSync());
    return files;
  }

  static _createPlayground() {
    new Directory('playground').createSync();

    new File('playground/pubspec.yaml').writeAsStringSync('''
name:${' '}
description: |
${'  '}
environment:
  sdk: '>=1.0.0 <2.0.0'
''');
    new File('playground/main.dart').writeAsStringSync('''
main() {
${'  '}
}''');
    new File('playground/index.html').writeAsStringSync('''
<!doctype html>
<html>
  <head>
  </head>
  <body>
    <script type="application/dart" src="main.dart"></script>
  </body>
</html>
''');
  }
}
