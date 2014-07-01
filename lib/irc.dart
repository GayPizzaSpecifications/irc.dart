/**
 * IRC for Dart
 */
library irc;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';

/* samrg472's event dispatching library */
import 'package:event_dispatcher/event_dispatcher.dart';

/* IRC Parsing Support */
import 'parser.dart';
export 'parser.dart';

/* Exports the Bot API */
export 'bot.dart';

/* Base IRC Client */
part 'src/client.dart';
/* IRC Events */
part 'src/events.dart';
/* IRC Types */
part 'src/types.dart';
/* Message Formatting */
part 'src/colors.dart';
/* WHOIS Stuff */
part 'src/whois.dart';

/* Client Pool */
part 'src/pool.dart';