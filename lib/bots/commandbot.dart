part of irc;

class CommandBot extends Bot {
    Client _client;

    Map<String, StreamController<CommandEvent>> commands = {
    };

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
        client().on(Events.Message).listen((MessageEvent event) {
            String message = event.message;

            if (message.startsWith(prefix)) {
                List<String> split = message.split(" ");

                String command = split[0].substring(1);

                List<String> args = new List.from(split);
                args.removeAt(0);

                if (commands.containsKey(command)) {
                    commands[command].add(new CommandEvent(event, command, args));
                }
            }
        });
    }

    Set<String> commandNames() {
        return commands.keys;
    }
}

class CommandEvent extends MessageEvent {
    static final EventType<CommandEvent> TYPE = new EventType<CommandEvent>();

    String command;
    List<String> args;

    CommandEvent(MessageEvent event, this.command, this.args) : super(event.client, event.from, event.target, event.message);
}
