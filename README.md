# Dart IRC

The Beautiful IRC Library for Dart that WORKS!

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

    bot.whenReady((ReadyEvent event) {
        event.join("#irc.dart");
    });

    bot.command("help").listen((MessageEvent event) {
        event.reply("> ${Color.BLUE}Commands${Color.RESET}: ${bot.commands.keys.join(', ')}");
    });

    bot.connect();
}
```

# Dumb Bot

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

    bot.whenReady((ReadyEvent event) {
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

    client.on(Events.Ready).listen((ReadyEvent event) {
        event.join("#DirectCode");
    });

    client.connect();
}
```

## Events

The following events are currently available:

- ReadyEvent: When the client is ready to join channels.
- JoinEvent: When a user joins a channel.
- MessageEvent: When the client receives a message.
- LineEvent: When the client receives a line from the IRC Server.
- SendEvent: When the client sends a line to the IRC Server.
- PartEvent When a user leaves a channel.
- ConnectEvent: When the client connects to the server.
- BotJoinEvent: When the client joins a channel.
- BotPartEvent: When the client leaves a channel.
- DisconnectEvent: When the client disconnects from the server.

To register an event handler on a Client or Bot, where client is a Client or Bot, `EventName` is the name of the event above without the 'Event' ending, and `SomeEvent` is the full name above:

```dart
client.on(Events.EventName).listen((SomeEvent event) {
    useTheEvent(event);
});
```