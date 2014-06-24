# Dart IRC [![Build Status](https://drone.io/github.com/DirectMyFile/irc.dart/status.png)](https://drone.io/github.com/DirectMyFile/irc.dart/latest)

The Beautiful IRC Library for Dart

Report any issues [here](https://github.com/DirectMyFile/irc.dart/issues/new)!

## Links

- [Wiki](https://github.com/DirectMyFile/irc.dart/wiki)
- [Issues](https://github.com/DirectMyFile/irc.dart/issues)

## Design

irc.dart is designed to work out of the box in a very configurable way.

- Optional Synchronous System
- Builtin Bot System
- Ability to create your own bots
- Easy to Understand API
- Use of a lot of Language Features
- Optionally use only what you need

## Bots

### Command Bot
The command bot is just a normal bot implementation of commands.

```dart
import 'package:irc/irc.dart';

void main() {
    BotConfig config = new BotConfig(
        host: "irc.freenode.net",
        port: 6667,
        nickname: "DartBot",
        username: "DartBot"
    );

    CommandBot bot = new CommandBot(config, prefix: ".");

    bot.register((ReadyEvent event) {
        event.join("#irc.dart");
    });

    bot.command("help").listen((CommandEvent event) {
        event.reply("> ${Color.BLUE}Commands${Color.RESET}: ${bot.commands.keys.join(', ')}");
    });

    bot.connect();
}
```

### Dumb Bot

This bot just prints messages to the console.

```dart
import 'package:irc/irc.dart';

void main() {
    BotConfig config = new BotConfig(
        host: "irc.freenode.net",
        port: 6667,
        nickname: "DartBot",
        username: "DartBot"
    );

    CommandBot bot = new DumbBot(config);

    bot.register((ReadyEvent event) {
        event.join("#irc.dart");
    });

    bot.connect();
}
```

## Library

There is also a plain library to write your own IRC Bots!

```dart
import 'package:irc/irc.dart';

void main() {
    BotConfig config = new BotConfig(
        host: "irc.esper.net",
        port: 6667,
        nickname: "DartBot",
        username: "DartBot"
    );

    Client client = new Client(config);

    client.register((ReadyEvent event) {
        event.join("#DirectCode");
    });

    client.connect();
}
```
