/**
 * A basic bot abstraction system
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

part 'src/bot/dumbbot.dart';
part 'src/bot/commandbot.dart';
part 'src/bot/base.dart';
part 'src/bot/logbot.dart';
