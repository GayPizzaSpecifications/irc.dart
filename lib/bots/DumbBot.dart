part of irc;

class DumbBot extends Bot {
  Client _client;
  List<String> channels = [];

  DumbBot(BotConfig config) {
    _client = new Client(config);
    _registerHandlers();
  }

  void _registerHandlers() {
    whenReady((ReadyEvent event) => channels.forEach((chan) => event.join(chan))
        );

    onMessage((MessageEvent event) => print(
        "<${event.target}><${event.from}> ${event.message}"));
  }

  @override
  Client client() => _client;
}
