/**
 * IRC for Dart
 */
library irc.client;

import "dart:io";
import "dart:async";
import "dart:convert";
import "dart:mirrors";

/* IRC Parsing Support */
import "parser.dart";
export "parser.dart";

/* IRC Event System */
import "event.dart";
export "event.dart";

/* Base Classes */
part "../src/legacy/client/base.dart";
part "../src/legacy/client/connection.dart";
/* IRC CRlient */
part "../src/legacy/client/client.dart";
/* IRC Events */
part "../src/legacy/client/events.dart";
/* IRC Types */
part "../src/legacy/client/config.dart";
/* Message Formatting */
part "../src/legacy/client/colors.dart";
/* WHOIS Stuff */
part "../src/legacy/client/who.dart";
/* Client Pool */
part "../src/legacy/client/pool.dart";
part "../src/legacy/client/entity.dart";
part "../src/legacy/client/channel.dart";
part "../src/legacy/client/user.dart";
part "../src/legacy/client/server.dart";
part "../src/legacy/client/helpers.dart";
