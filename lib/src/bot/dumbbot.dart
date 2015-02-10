part of irc.bot;

class DumbBot extends Bot {
  Client _client;
  Client get client => _client;

  List<String> channels = [];

  DumbBot(Configuration config) {
    _client = new Client(config);
    _registerHandlers();
  }

  void _registerHandlers() {
    register((ReadyEvent event) => channels.forEach((chan) => event.join(chan)));

    register((MessageEvent event) => print("<${event.target}><${event.from}> ${event.message}"));
  }
}
