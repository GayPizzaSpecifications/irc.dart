part of irc;

class BotConfig {
    String host;
    int port;
    String nickname;
    String realname;
    String username;

    BotConfig({this.host: "irc.esper.net", this.port: 6667, this.nickname:"DartBot", this.username: "DartBot", this.realname: "Dart IRC Bot"});
}

class Channel {
    Client _client;
    String name;

    Channel(Client client, this.name) {
        _client = client;
    }

    void message(String message) {
        _client.message(name, message);
    }

    void notice(String message) {
        _client.notice(name, message);
    }

    bool operator ==(Channel channel) => this.name == channel.name;
}
