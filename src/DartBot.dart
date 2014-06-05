library DartBot;

import "dart:io";
import "dart:async";
import "dart:convert";
import "package:irc_message/irc_message.dart" as IRCParser;
import 'package:event_bus/event_bus.dart';

part "IRCClient.dart";
part "Events.dart";
part "BotConfig.dart";