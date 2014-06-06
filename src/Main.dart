import "DartBot.dart";

void main() {
    IRCClient client = new IRCClient(new BotConfig());

    IRCClient.debug(client);

    client.on(Events.Ready).listen((ReadyEvent event) {
        client.join("#DirectCode");
    });

    client.on(Events.Join).listen((JoinEvent event) {
        event.reply("Hello! I'm DartBot, the best IRC Bot written in Dart!");
    });

    client.on(Events.Message).listen((MessageEvent event) {
        event.reply("Such Message, Much Wow");
    });

    client.connect();
}