/**
 * Bot API
 *
 * All Bots extend [Bot].
 *
 * # Bots
 * ## CommandBot
 *
 * A bot with command registration and handling.
 *
 * ## LogBot
 *
 * A bot with a logger to the disk.
 *
 * ## DumbBot
 *
 * A bot that just sits in the channel.
 */
library irc.bot;

import 'package:irc/irc.dart';
import 'dart:async';
import 'dart:io';

/* Bot API Base */
part 'src/bot/base.dart';
/* Dumb IRC Bot */
part 'src/bot/dumbbot.dart';
/* Command IRC Bot */
part 'src/bot/commandbot.dart';
/* Logging IRC Bot */
part 'src/bot/logbot.dart';
