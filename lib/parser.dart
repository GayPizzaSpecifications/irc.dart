/**
 * IRC Line Parsing Support
 */
library irc.parser;

import "dart:convert" show Converter, StringConversionSink, StringConversionSinkBase;

part 'src/parser/base.dart';
part 'src/parser/message.dart';
part 'src/parser/regex.dart';