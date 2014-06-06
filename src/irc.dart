library irc;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:irc_message/irc_message.dart' as IRCParser;
import 'package:event_bus/event_bus.dart';

part 'client.dart';
part 'bot.dart';
part 'events.dart';
part 'types.dart';
part 'bots/CommandBot.dart';
part 'colors.dart';

/**
 * Temporary Fix for Hostmask Parsing
 */
Map<String, String> _parse_hostmask(IRCParser.Message message) {
    return message.getHostmask() as Map<String, String>;
}