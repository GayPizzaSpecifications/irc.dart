part of DartBot;

class BotConfig {
    String host;
    int port;
    String nickname;
    String realname;
    String username;

    BotConfig({this.host: "irc.esper.net", this.port: 6667, this.nickname: "DartBot", this.username: "DartBot", this.realname: "Dart IRC Bot"});
}
