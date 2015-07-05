/**
 * IRC for Dart
 */
library irc.client;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';

/* samrg472's event dispatching library */
import 'package:event_dispatcher/event_dispatcher.dart';

/* IRC Parsing Support */
import 'parser.dart';
export 'parser.dart';

/* Base Classes */
part 'src/client/base.dart';
part 'src/client/connection.dart';
/* IRC Client */
part 'src/client/client.dart';
/* IRC Events */
part 'src/client/events.dart';
/* IRC Types */
part 'src/client/config.dart';
/* Message Formatting */
part 'src/client/colors.dart';
/* WHOIS Stuff */
part 'src/client/who.dart';
/* Client Pool */
part 'src/client/pool.dart';
part 'src/client/channel.dart';

