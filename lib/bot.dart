/**
 * Bot Abstraction API
 *
 * All Bots extend [Bot].
 * Each bot should have its own purpose.
 */
library irc.bot;

import 'package:irc/client.dart';
import 'dart:async';
import 'dart:io';

/* Bot API Base */
part 'src/bot/base.dart';
part 'src/bot/behaviors.dart';
/* Dumb IRC Bot */
part 'src/bot/dumbbot.dart';
/* Command IRC Bot */
part 'src/bot/commandbot.dart';
/* Logging IRC Bot */
part 'src/bot/logbot.dart';
