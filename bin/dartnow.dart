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
  runner = new CommandRunner("dartnow", "DartNow manager.")
    ..addCommand(new InitCommand())
    ..addCommand(new CreateCommand())
    ..addCommand(new PushCommand())
    ..addCommand(new AddCommand())
    ..addCommand(new UpdateGistCommand())
    ..addCommand(new ResetCommand())
  ;

  runner.run(arguments);
}

class PushCommand extends Command {
  final name = "push";
  final description = """
pull changes (just to be sure)
commit changes from git dir
push changes from git dir
command add_snippet
pull changes back locally
  """;

  DartNow dartnow;

  String get dir => argResults.rest[0];

  PushCommand();

  run() async {
    dartnow = new DartNow();
    await dartnow.push(dir);
    exit(0);
  }


}


class InitCommand extends Command {
  final name = "init";
  final description = "Init command.";

  InitCommand();

  run() async {
    DartNow.addConfig();
    DartNow.createPlayground();
    exit(0);
  }
}


/// Create a new gist from playground dir.
class CreateCommand extends Command {
  final name = "create";
  final description = "Create a new gist from playground dir.";

  DartNow dartnow;

  CreateCommand();

  run() async {
    dartnow = new DartNow();
    Gist gist = await dartnow.createGist();

    // Add command
    String id = gist.id;
    await dartnow.add(id);

    DartNow.resetPlayground();
    await dartnow.cloneGist(id);
    exit(0);
  }
}

/// Update a gist.
class UpdateGistCommand extends Command {
  final name = "update_gist";
  final description =
      "Update a gist. The argument should be the id of the gist";
  DartNow dartnow;

  String get id => argResults.rest[0];

  UpdateGistCommand();

  run() async {
    dartnow = new DartNow();
    await dartnow.updateGist(id);
    exit(0);
  }
}

/// Add an gist id to firebase.
class AddCommand extends Command {
  final name = "add";
  final description = "Add an gist id to firebase.";
  DartNow dartnow;

  String get id => argResults.rest[0];

  AddCommand();

  run() async {
    dartnow = new DartNow();
    await dartnow.add(id);

    exit(0);
  }
}

class ResetCommand  extends Command {
  final name = "reset";
  final description = "Reset the playground dir.";

  ResetCommand();

  run() async {
    DartNow.resetPlayground();
    exit(0);
  }
}
