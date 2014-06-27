library hop_runner;

import 'dart:async';
import "dart:io";

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:yaml/yaml.dart';

part 'docgen.dart';
part 'utils.dart';
part 'version.dart';

void main(List<String> args) {
  addTask("docs", createDocGenTask("."));
  addTask("analyze", createAnalyzerTask(["lib/irc.dart", "example/log.dart", "example/debug.dart", "example/example.dart"]));
  addTask("version", createVersionTask());
  addTask("publish", createProcessTask("pub", args: ["publish", "-f"], description: "Publishes a New Version"), dependencies: ["version"]);
  addChainedTask("check", ["analyze"]);
  runHop(args);
}