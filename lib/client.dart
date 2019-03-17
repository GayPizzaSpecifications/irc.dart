/// IRC for Dart
library irc.client;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';

// Import pedantic for unawaited
import 'package:pedantic/pedantic.dart';

/* IRC Parsing Support */
import 'parser.dart';
export 'parser.dart';

/* IRC Event System */
import 'event.dart';
export 'event.dart';

// Base Classes
part 'src/client/base.dart';
part 'src/client/connection.dart';

// IRC client
part 'src/client/client.dart';

// IRC events
part 'src/client/events.dart';

// IRC config
part 'src/client/config.dart';

// Message formatting
part 'src/client/colors.dart';

// WHOIS
part 'src/client/who.dart';

// Client pool
part 'src/client/pool.dart';
part 'src/client/entity.dart';
part 'src/client/channel.dart';
part 'src/client/user.dart';
part 'src/client/server.dart';
part 'src/client/helpers.dart';
