library irc;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:irc_message/irc_message.dart' as IRCParser;

import 'package:event_bus/event_bus.dart' show EventBus, EventType;
export 'package:event_bus/event_bus.dart' show EventType, EventBus;

export 'bot.dart';

part 'src/client.dart';
part 'src/events.dart';
part 'src/types.dart';
part 'src/colors.dart';
