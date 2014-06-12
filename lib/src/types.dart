part of irc;

class BotConfig {
  String host;
  int port;
  String nickname;
  String realname;
  String username;
  bool synchronous;

  BotConfig({this.host: "irc.esper.net", this.port: 6667, this.nickname:"DartBot", this.username: "DartBot", this.realname: "Dart IRC Bot", this.synchronous: false});
}

class Channel {
  Client client;
  String name;

  Channel(this.client, this.name);

  void message(String message) => client.message(name, message);

  void notice(String message) => client.notice(name, message);

  void op(String user) => mode("+o", user);

  void deop(String user) => mode("-o", user);

  void voice(String user) => mode("+v", user);

  void devoice(String user) => mode("-v", user);

  void mode(String mode, [String user = null]) {
    if (user != null) {
      client.send("MODE ${name} ${mode} ${user}");
    } else {
      client.send("MODE ${name} ${mode}");
    }
  }

  bool operator ==(Channel channel) => this.name == channel.name;
}
