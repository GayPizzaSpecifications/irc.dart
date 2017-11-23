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
part "src/client/base.dart";
part "src/client/connection.dart";
/* IRC CRlient */
part "src/client/client.dart";
/* IRC Events */
part "src/client/events.dart";
/* IRC Types */
part "src/client/config.dart";
/* Message Formatting */
part "src/client/colors.dart";
/* WHOIS Stuff */
part "src/client/who.dart";
/* Client Pool */
part "src/client/pool.dart";
part "src/client/entity.dart";
part "src/client/channel.dart";
part "src/client/user.dart";
part "src/client/server.dart";
part "src/client/helpers.dart";
