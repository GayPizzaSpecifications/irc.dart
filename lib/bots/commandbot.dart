part of irc;

class CommandBot extends Bot {
    Client _client;

    Map<String, StreamController<MessageEvent>> commands = {
    };

    String prefix;

    CommandBot(BotConfig config, {this.prefix: "!"}) {
        _client = new Client(config);
        _registerHandlers();
    }

    @override
    Client client() => _client;

    Stream<MessageEvent> command(String name) {
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

                if (commands.containsKey(command)) {
                    commands[command].add(event);
                }
            }
        });
    }
}
