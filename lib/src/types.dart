part of irc;

class BotConfig {
  String host;
  int port;
  String nickname;
  String realname;
  String username;

  BotConfig({this.host: "irc.esper.net", this.port: 6667, this.nickname:"DartBot", this.username: "DartBot", this.realname: "Dart IRC Bot"});

  BotConfig.fromMap(Map<String, Object> map) {
    host = map["host"];
    port = map["port"];
    nickname = map["nickname"];
    username = map["username"];
  }
}

class Channel {
  final Client client;
  final String name;
  final Set<String> ops = new Set<String>();
  final Set<String> voices = new Set<String>();
  final Set<String> members = new Set<String>();

  String _topic;

  String get topic => _topic;

  void set topic(String topic) => client.send("TOPIC ${name} :${topic}");

  Set<String> get allUsers {
    Set<String> all = new Set<String>();
    all.addAll(ops);
    all.addAll(voices);
    all.addAll(members);
    return all;
  }

  Channel(this.client, this.name);

  void message(String message) => client.message(name, message);

  void notice(String message) => client.notice(name, message);

  void op(String user) => mode("+o", user);

  void deop(String user) => mode("-o", user);

  void voice(String user) => mode("+v", user);

  void devoice(String user) => mode("-v", user);

  void ban(String user) => mode("+b", user);

  void unban(String user) => mode("-b", user);

  void kick(String user) => client.send("KICK ${name} ${user}");

  void kickban(String user) {
    ban(user);
    kick(user);
  }

  void action(String msg) {
    message("\u0001ACTION ${msg}\u0001");
  }

  void mode(String mode, [String user = null]) {
    if (user != null) {
      client.send("MODE ${name} ${mode} ${user}");
    } else {
      client.send("MODE ${name} ${mode}");
    }
  }

  bool operator ==(Channel channel) => this.name == channel.name;
}