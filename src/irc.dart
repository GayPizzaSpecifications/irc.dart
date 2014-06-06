library irc;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:irc_message/irc_message.dart' as IRCParser show Message, MessageParser;

import 'package:event_bus/event_bus.dart' show EventType, EventBus;

part 'client.dart';
part 'bot.dart';
part 'events.dart';
part 'types.dart';
part 'colors.dart';

part 'bots/CommandBot.dart';
part 'bots/DumbBot.dart';

/**
 * Temporary Fix for Hostmask Parsing
 */

Map<String, String> _parse_hostmask(IRCParser.Message message) {
    return message.getHostmask() as Map<String, String>;
}