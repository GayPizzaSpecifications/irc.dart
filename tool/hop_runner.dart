library hop_runner;

import 'dart:async';
import "dart:io";

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:quiver/async.dart';
import 'package:quiver/io.dart';

part 'docgen.dart';
part 'utils.dart';

void main(List<String> args) {
    addTask("docs", createDocGenTask("."));
    addTask("analyze", createAnalyzerTask(["lib/irc.dart"]));
    addChainedTask("check", ["analyze"]);
    runHop(args);
}
