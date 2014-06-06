part of irc;

class CommandBot {
  Client _client;

  Map<String, StreamController<MessageEvent>> commands = {};

  String prefix;

  CommandBot(BotConfig config, {this.prefix: "!"}) {
    _client = new Client(config);
    _registerHandlers();
  }

  Client client() => _client;

  void connect() => _client.connect();

  void disconnect() => _client.disconnect();

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

  StreamSubscription<ReadyEvent> ready(Function handler) {
    return on(Events.Ready).listen(handler);
  }

  Stream<Event> on(EventType<Event> type) => client().on(type);
}
