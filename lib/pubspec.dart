library dartnow.pubspec;

import 'package:yaml/yaml.dart';

class PubSpec {
  final String name;
  final String description;
  final String homepage;
  final Map dependencies;
  final Map yaml;

  String _mainLibrary;
  String get mainLibrary => _mainLibrary;
  String _mainElements;
  String get mainElements => _mainElements;
  String _tags;
  String get tags => _tags;

  PubSpec.fromString(String string) :
  this._fromMap(loadYaml(string));

  PubSpec._fromMap(Map yaml)
  : this.yaml = yaml,
  name = yaml['name'],
  description = yaml['description'],
  homepage = yaml['homepage'],
  dependencies = yaml['dependencies'],
  _tags = yaml['tags'],
  _mainElements = yaml['main_elements'],
  _mainLibrary = yaml['main_library'] {
    if (name == null || name.isEmpty) {
      throw 'Please specify a name in your pubspec.';
    }
    if (_mainLibrary == null) {
      _mainLibrary = name.substring(0, _libraryEndIndex).replaceAll('.', ':');
    }
    if (_mainElements == null || _tags == null) {
      _findElementAndTags();
    }
  }

  String get id => homepage.substring(homepage.lastIndexOf('/')+ 1);

  int get _libraryEndIndex {
    if (name.contains('__')) {
      return name.indexOf('__');
    } else if (name.contains('_')) {
      return name.indexOf('_');
    } else {
      return name.length;
    }
  }

  void _findElementAndTags() {
    StringBuffer buffer = new StringBuffer();
    bool skipUnderscore = false;
    String newTags = "";
    String newElements = "";
    for (int i = _libraryEndIndex; i < name.length; i++) {
      if (name[i] != '_' || skipUnderscore) buffer.write(name[i]);
      if (name[i] == "'") {
        skipUnderscore = !skipUnderscore;
      }
      if ((name[i] == '_' || i == name.length - 1) && !skipUnderscore) {
        // add the buffer to the tags or mainElements
        if (buffer.length > 1) {
          String string = '$buffer ';
          if (string.contains("'")) {
            newTags += string.replaceAll("'", '');
          } else {
            newElements += string;
          }
          // create a new buffer
          buffer = new StringBuffer();
        }
      }
    }
    if (mainElements == null) {
      _mainElements = newElements.trim();
    }
    if (tags == null) {
      _tags = newTags.trim();
    }
  }
}
