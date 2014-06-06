library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:hop_docgen/hop_docgen.dart';

void main(List<String> args) {
    addTask("docs", createDocGenTask("."));
    runHop(args);
}