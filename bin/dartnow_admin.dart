import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:dartnow/dartnow.dart';
import 'package:dartnow/dart_snippet.dart';
import 'package:github/server.dart';
import 'package:prompt/prompt.dart';
import 'dart:convert';
import 'package:dartnow/dartnow_admin.dart';
import 'package:dartnow/dartnow_user.dart';

CommandRunner runner;

void main(List<String> arguments) {
  runner = new CommandRunner("dartnow_admin", "DartNow manager.")

    ..addCommand(new UpdateCommand())
    ..addCommand(new UpdateNew())
    ..addCommand(new DeleteNewCommand())
    ..addCommand(new DeleteGistCommand())
    ..addCommand(new UpdateUserCommand())
  ;

  runner.run(arguments);
}

class UpdateCommand extends Command {
  final name = "update";
  final description = """
  calculate snippet model
  add info to firebase
  command update_user [snippet.username]
  """;

  DartNowAdmin dartnow;

  String get id => argResults.rest[0];

  UpdateCommand();

  run() async {
    dartnow = new DartNowAdmin();
    await dartnow.update(id);
    exit(0);
  }
}


class UpdateNew extends Command {
  final name = "update_new";
  final description = """
  fetch all new ids
  command update [id]
  """;

  DartNowAdmin dartnow;

  String get id => argResults.rest[0];

  UpdateNew();

  run() async {
    dartnow = new DartNowAdmin();
    await dartnow.updateNew();
    exit(0);
  }
}


class DeleteGistCommand extends Command {
  final name = "delete";
  final description = """
  delete
  """;

  DartNowAdmin dartnow;

  String get id => argResults.rest[0];

  DeleteGistCommand();

  run() async {
    dartnow = new DartNowAdmin();
    await dartnow.deleteGist(id);
    exit(0);
  }
}


class DeleteNewCommand extends Command {
  final name = "delete_new";
  final description = """
  delete
  """;

  DartNowAdmin dartnow;

  String get id => argResults.rest[0];

  DeleteNewCommand();

  run() async {
    dartnow = new DartNowAdmin();
    await dartnow.deleteNew(id);
    exit(0);
  }
}

class UpdateUserCommand extends Command {
  final name = "update_user";
  final description = """
  Update user
  """;

  DartNowAdmin dartnow;

  String get username => argResults.rest[0];

  UpdateUserCommand();

  run() async {
    dartnow = new DartNowAdmin();
    await dartnow.updateUser(username);
    exit(0);
  }
}

