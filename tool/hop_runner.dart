library hop_runner;

import 'dart:async';
import "dart:io";

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart' hide createAnalyzerTask;
import 'package:yaml/yaml.dart';

part 'docgen.dart';
part 'utils.dart';
part 'version.dart';
part 'analyze.dart';

var files = ["lib/irc.dart", "example/log.dart", "example/debug.dart", "example/example.dart", "example/parsing.dart"];

void main(List<String> args) {
  addTask("docs", createDocGenTask(".", out_dir: "out/docs"));
  addTask("analyze", createAnalyzerTask(files));
  addTask("version", createVersionTask());
  addTask("publish", createProcessTask("pub", args: ["publish", "-f"], description: "Publishes a New Version"), dependencies: ["version"]);
  addTask("bench", createBenchTask());
  addTask("test", createProcessTask("dart", args: ["--checked", "test/all_tests.dart"]));
  addChainedTask("check", ["analyze", "test"]);
  runHop(args);
}
