library all_tests;

import 'package:test/test.dart';

import 'parser_tests.dart' as parser_tests;

void main() {
  group('Parser', parser_tests.main);
}
