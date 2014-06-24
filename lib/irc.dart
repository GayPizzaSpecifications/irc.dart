library irc;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';
import 'dart:math' as Math;

import 'package:event_dispatcher/event_dispatcher.dart';

import 'parser.dart';

export 'bot.dart';

part 'src/client.dart';
part 'src/events.dart';
part 'src/types.dart';
part 'src/colors.dart';
part 'src/whois.dart';