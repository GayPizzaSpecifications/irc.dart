part of irc.bot;

class LogBot extends Bot {
  Client _client;
  List<String> channels = [];
  Directory _logLocation;
  Directory _channelLogs;

  LogBot(BotConfig config, String location) {
    _client = new Client(config);
    _logLocation = new Directory(location);
    _channelLogs = new Directory("${location}/channels");
    if (!_channelLogs.existsSync()) {
      _channelLogs.createSync(recursive: true);
    }
    _logLocation = _channelLogs.parent;
    _registerHandlers();
  }

  void _registerHandlers() {
    register((ReadyEvent event) => channels.forEach((chan) => event.join(chan)));

    register((BotJoinEvent event) {
      writeToLog("Joined ${event.channel.name}");
    });

    register((BotPartEvent event) {
      writeToLog("Left ${event.channel.name}");
    });

    register((JoinEvent event) {
      writeToLog("${event.user} joined the channel", channel: event.channel);
    });

    register((PartEvent event) {
      writeToLog("${event.user} left the channel", channel: event.channel);
    });

    register((MessageEvent event) {
      String line = "<${event.from}> ${event.message}";
      print("<${event.target}>${line}");
      writeToLog(line, channel: event.channel);
    });
  }

  void writeToLog(String message, {Channel channel: null}) {
    File file = new File("${_logLocation.path}/bot.log");
    if (channel != null) {
      file = new File("${_channelLogs.path}/${channel.name.substring(1)}.log");
    }
    if (file.existsSync()) {
      file.createSync();
    }
    file.writeAsString(message + "\n", mode: FileMode.APPEND);
  }

  @override
  Client client() => _client;
}
