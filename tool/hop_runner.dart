library hop_runner;

import 'dart:async';
import "dart:io";

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:quiver/async.dart';
import 'package:quiver/io.dart';
import "package:yaml/yaml.dart" hide loadYamlStream, loadYamlNode;

part 'docgen.dart';
part 'utils.dart';

void main(List<String> args) {
    addTask("docs", createDocGenTask("."));
    runHop(args);
}