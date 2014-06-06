part of DartBot;

class Channel {
    IRCClient _client;
    String name;

    Channel(IRCClient client, this.name) {
        _client = client;
    }

    void message(String message) {
        _client.message(name, message);
    }

    void notice(String message) {
        _client.notice(name, message);
    }
}