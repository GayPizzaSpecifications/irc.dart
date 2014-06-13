library hop_runner;

import 'dart:async';
import "dart:io";

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:quiver/async.dart';
import 'package:quiver/io.dart';
import 'package:yaml/yaml.dart';

part 'docgen.dart';
part 'utils.dart';
part 'version.dart';

void main(List<String> args) {
    addTask("docs", createDocGenTask("."));
    addTask("analyze", createAnalyzerTask(["lib/irc.dart"]));
    addTask("version", createVersionTask());
    addChainedTask("check", ["analyze"]);
    runHop(args);
}
