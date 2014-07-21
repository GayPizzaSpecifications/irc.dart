part of irc.bot;

typedef CommandHandler(CommandEvent event);

/**
 * Command Bot - Fully Customizable
 */
class CommandBot extends Bot {
  Client _client;

  Client get client => _client;

  Map<String, StreamController<CommandEvent>> commands = {};

  CommandHandler commandNotFound = (event) => null;

  String prefix;

  CommandBot(BotConfig config, {this.prefix: "!"}) {
    _client = new Client(config);
    _registerHandlers();
  }

  void command(String name, CommandHandler handler) {
    commands.putIfAbsent(name, () {
      return new StreamController.broadcast();
    }).stream.listen(handler);
  }

  void _registerHandlers() {
    register(handleAsCommand);
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

  Iterable<String> commandNames() => commands.keys;
}

class CommandEvent extends MessageEvent {
  String command;
  List<String> args;

  CommandEvent(MessageEvent event, this.command, this.args)
      : super(event.client, event.from, event.target, event.message);

  bool checkArguments(int size, String help) {
    if (args.length != size) {
      reply(help);
      return false;
    }
    return true;
  }

  void notice(String message, {bool user: true}) => client.notice(user ? from : target, message);

  void act(String message) => channel.action(message);

  String argument(int index) => args[index];
}
