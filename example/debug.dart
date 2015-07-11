import "dart:async";

import "package:irc/client.dart";

typedef CommandHandler(CommandEvent event);

String prefix = "~";
Map<String, StreamController<CommandEvent>> commands = {};

void main() {
  var config = new Configuration(
    host: "irc.esper.net",
    port: 6667,
    nickname: "DartBotDebug",
    username: "DartBot",
    realname: "DartBotDebug"
  );
  var client = new Client(config);
  client.connect();

  client.onLineSent.listen((event) {
    print(">> ${event.line}");
  });
  client.onLineReceive.listen((event) {
    print("<< ${event.line}");
  });
  client.onMode.listen((event) {
    if (event.channel != null && event.user != null) {
      print("Mode (${event.mode}) given to ${event.user} in ${event.channel.name}");
    } else if (event.channel != null) {
      print("Mode (${event.mode}) given to ${event.channel.name}");
    } else if (event.user != null) {
      print("Mode (${event.mode}) was set on us.");
    }
  });
  client.onReady.listen((event) {
    event.join("#directcode");
  });
  client.register(handleAsCommand);

  command("notice-me", (CommandEvent event) {
    event.notice("This is a test notice to you");
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
    } else if (event.args.length == 0) {
      client.part(event.channel.name);
    } else {
      event.reply("Usage: part [channel]");
    }
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
      return users.map((it) {
        return it.nickname;
      }).toList().join(", ");
    }

    if (event.target.isChannel) {
      Channel target = event.target;
      event.notice("> Members: ${joinNicks(target.members)}");
      event.notice("> Ops: ${joinNicks(target.ops)}");
      event.notice("> Voices: ${joinNicks(target.voices)}");
      event.notice("> Owners: ${joinNicks(target.owners)}");
      event.notice("> Half-Ops: ${joinNicks(target.halfops)}");
      event.notice("> All Users: ${joinNicks(target.allUsers)}");
    }
  });

  command("act", (CommandEvent event) {
    event.act("is silleh.");
  });

  command("away", (CommandEvent event) {
    print(event.args.length);
    if (event.args.length == 1) {
      User user = client.getUser(event.args[0]);
      user.isAway().then((away) {
        event.reply("$away");
      });
    }
  });
}

void handleAsCommand(MessageEvent event) {
  String message = event.message;

  if (message.startsWith(prefix)) {
    var end = message.contains(" ") ? message.indexOf(" ", prefix.length) : message.length;
    var command = message.substring(prefix.length, end);
    var args = message.substring(end != message.length ? end + 1 : end).split(" ");

    args.removeWhere((i) => i.isEmpty || i == " ");

    if (commands.containsKey(command)) {
      commands[command].add(new CommandEvent(event, command, args));
    } else {
      commandNotFound(new CommandEvent(event, command, args));
    }
  }
}

void command(String name, CommandHandler handler) {
  commands.putIfAbsent(name, () {
    return new StreamController.broadcast();
  }).stream.listen(handler);
}

void commandNotFound(CommandEvent event) {
  event.reply("Command not found.");
}

class CommandEvent extends MessageEvent {
  String command;
  List<String> args;

  CommandEvent(MessageEvent event, this.command, this.args)
  : super(event.client, event.from, event.target, event.message);

  void notice(String message, {bool user: true}) => client.sendNotice(user ? from : target.name, message);

  void act(String message) => client.sendAction(target.name, message);

  String argument(int index) => args[index];
}