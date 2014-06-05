import "DartBot.dart";

void main() {
    IRCClient client = new IRCClient(new BotConfig());

    IRCClient.debug(client);

    client.on(Events.Ready).listen((ReadyEvent event) {
        client.join("#DirectCode");
    });

    client.connect();
}