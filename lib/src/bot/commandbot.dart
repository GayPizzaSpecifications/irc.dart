part of irc.bot;

class CommandBot extends Bot {
  Client _client;

  Map<String, StreamController<CommandEvent>> commands = {
  };

  Function commandNotFound = (CommandEvent event) => null;

  String prefix;

  CommandBot(BotConfig config, {this.prefix: "!"}) {
    _client = new Client(config);
    _registerHandlers();
  }

  @override
  Client client() => _client;

  Stream<CommandEvent> command(String name) {
    return commands.putIfAbsent(name, () {
      return new StreamController.broadcast();
    }).stream;
  }

  void _registerHandlers() {
    register(handleAsCommand);
  }

  void handleAsCommand(MessageEvent event) {
    String message = event.message;

    if (message.startsWith(prefix)) {
      List<String> split = message.split(" ");

      String command = split[0].substring(prefix.length);

      List<String> args = new List.from(split);
      args.removeAt(0);

      if (commands.containsKey(command)) {
        commands[command].add(new CommandEvent(event, command, args));
      } else {
        commandNotFound(new CommandEvent(event, command, args));
      }
    }
  }

  Set<String> commandNames() => commands.keys;
}

class CommandEvent extends MessageEvent {
  String command;
  List<String> args;

  CommandEvent(MessageEvent event, this.command, this.args) : super(event.client, event.from, event.target, event.message);

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
