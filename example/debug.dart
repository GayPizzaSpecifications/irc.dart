import 'dart:async';

import 'package:irc/client.dart';

typedef CommandHandler(CommandEvent event);

String prefix = '~';
Map<String, StreamController<CommandEvent>> commands = {};

void main() {
  var config = new Configuration(
      host: 'irc.freenode.net',
      port: 6667,
      nickname: 'DartBotDebug',
      username: 'DartBotDebug',
      realname: 'DartBotDebug');

  var client = new Client(config);
  client.connect();

  client.onLineSent.listen((event) {
    print("<< ${event.line}");
  });

  client.onLineReceive.listen((event) {
    print(">> ${event.line}");
  });

  client.onDisconnect.listen((e) async {
    await new Future.delayed(const Duration(seconds: 1));
    client.connect();
  });

  client.onMode.listen((event) {
    if (event.channel != null && event.user != null) {
      print(
          "Mode (${event.mode}) given to ${event.user} in ${event.channel.name}");
    } else if (event.channel != null) {
      print("Mode (${event.mode}) given to ${event.channel.name}");
    } else if (event.user != null) {
      print("Mode (${event.mode}) was set on us.");
    }
  });

  client.onReady.listen((event) {
    event.join("#spinlocklabs");

    if (client.monitor.isSupported) {
      client.monitor.add("kaendfinger");
    }
  });

  client.register(handleAsCommand);

  command("notice-me", (CommandEvent event) {
    event.notice("This is a test notice to you");
  });

  command("server-caps", (CommandEvent e) {
    e.reply("Supported: ${client.supported}");
    e.reply("Capabilities: ${client.serverCapabilities.join(', ')}");
  });

  command("notice-chan", (CommandEvent event) {
    event.notice("This is a test notice to the channel", user: false);
  });

  command("join", (CommandEvent event) {
    if (event.args.length == 1) {
      client.join(event.args[0]);
    } else {
      event.reply("Usage: join <channel>");
    }
  });

  command("part", (CommandEvent event) {
    if (event.args.length == 1) {
      client.part(event.args[0]);
    } else if (event.args.isEmpty) {
      client.part(event.channel.name);
    } else {
      event.reply("Usage: part [channel]");
    }
  });

  command("quit", (CommandEvent event) {
    client.disconnect(reason: "${event.from.name} asked me to quit.");
  });

  command("topic", (CommandEvent event) {
    event.reply(event.channel.topic);
  });

  command("bans", (CommandEvent event) {
    event.reply("${event.channel.bans}");
  });

  command("spam", (CommandEvent event) {
    for (var i = 1; i <= 50; i++) {
      event.reply(i.toString());
    }
  });

  command("users", (CommandEvent event) {
    String joinNicks(Set<User> users) {
      if (users.length > 10) {
        return "${users.length} users";
      }
      return users
          .map((it) {
            return it.nickname;
          })
          .toList()
          .join(", ");
    }

    if (!event.target.isChannel) {
      return;
    }

    Channel channel = event.target;
    if (event.args.isNotEmpty) {
      channel = client.getChannel(event.args[0]);
    }

    if (channel == null) {
      event.notice("${event.args[0]} not found.");
      return;
    }

    event.notice("> Members: ${joinNicks(channel.members)}");
    event.notice("> Ops: ${joinNicks(channel.ops)}");
    event.notice("> Voices: ${joinNicks(channel.voices)}");
    event.notice("> Owners: ${joinNicks(channel.owners)}");
    event.notice("> Half-Ops: ${joinNicks(channel.halfops)}");
    event.notice("> All Users: ${joinNicks(channel.allUsers)}");
  });

  command("act", (CommandEvent event) {
    event.act("is silleh.");
  });

  command("whois", (CommandEvent event) async {
    if (event.args.length != 1) {
      event.reply("Usage: whois <user>");
      return;
    }

    var whois = await client.whois(event.args[0]);
    var info = whois.toString();
    event.notice(info);
  });

  command("away", (CommandEvent event) async {
    if (event.args.length == 1) {
      User user = client.getUser(event.args[0]);
      var isAway = await user.isAway();
      if (isAway) {
        event.reply("${user.name} is away.");
      } else {
        event.reply("${user.name} is not away.");
      }
    }
  });

  command("server-version", (CommandEvent e) async {
    var version = await client.getServerVersion();
    e.reply("Server: ${version.server}, Version: ${version.version}");
  });

  command("online", (CommandEvent e) {
    if (e.args.length != 1) {
      return;
    }

    e.reply("Online: ${client.monitor.isUserOnline(e.args[0])}");
  });
}

void handleAsCommand(MessageEvent event) {
  String message = event.message;

  if (message.startsWith(prefix)) {
    var end = message.contains(" ")
        ? message.indexOf(" ", prefix.length)
        : message.length;
    var command = message.substring(prefix.length, end);
    var args =
        message.substring(end != message.length ? end + 1 : end).split(" ");

    args.removeWhere((i) => i.isEmpty || i == " ");

    if (commands.containsKey(command)) {
      commands[command].add(new CommandEvent(event, command, args));
    } else {
      commandNotFound(new CommandEvent(event, command, args));
    }
  }
}

void command(String name, CommandHandler handler) {
  commands
      .putIfAbsent(name, () {
        return new StreamController.broadcast();
      })
      .stream
      .listen((e) async {
        try {
          await handler(e);
        } catch (e, stack) {
          print(e);
          print(stack);
        }
      }, onError: (e, stack) {
        print(e);
        print(stack);
      });
}

void commandNotFound(CommandEvent event) {
  event.reply("Command not found.");
}

class CommandEvent extends MessageEvent {
  String command;
  List<String> args;

  CommandEvent(MessageEvent event, this.command, this.args)
      : super(event.client, event.from, event.target, event.message);

  void notice(String message, {bool user = true}) =>
      client.sendNotice(from.name, message);

  void act(String message) => client.sendAction(target.name, message);

  String argument(int index) => args[index];
}
