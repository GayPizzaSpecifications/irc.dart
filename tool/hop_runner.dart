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

Map<String, dynamic> config = load_config();

Directory get tool_dir => new File.fromUri(Platform.script).parent.absolute;
Directory get root_dir => tool_dir.parent;

Map<String, dynamic> load_config() => loadYaml(new File("${tool_dir.path}/build.yaml").readAsStringSync());

Map<String, dynamic> variables = {
  "tool_dir": tool_dir.path,
  "root_dir": root_dir.path
};

String parse_value(String input) {
  var out = input;
  for (var variable in variables.keys) {
    out = out.replaceAll("{${variable}}", variables[variable]);
  }
  return out;
}

void main(List<String> args) {
  Directory.current = root_dir;
  addTask("docs", createDocGenTask(".", out_dir: parse_value(config["docs"]["output"])));
  addTask("analyze", createAnalyzerTask(config["analyzer"]["files"].map(parse_value)));
  addTask("version", createVersionTask());
  addTask("publish", createProcessTask("pub", args: ["publish", "-f"], description: "Publishes a New Version"), dependencies: ["version"]);
  addTask("bench", createBenchTask());
  addTask("test", createProcessTask("dart", args: ["--checked", parse_value(config["test"]["file"])], description: "Runs Unit Tests"));
  addChainedTask("check", config["check"]["tasks"].map(parse_value).toList(), description: "Runs the Dart Analyzer and Unit Tests");
  runHop(args);
}
