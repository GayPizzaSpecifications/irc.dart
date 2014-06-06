import '../src/irc.dart';

void main() {
    BotConfig config = new BotConfig(
        host: "irc.freenode.net",
        port: 6667,
        nickname: "DartBot",
        username: "DartBot"
    );

    CommandBot bot = new CommandBot(config, prefix: ".");

    bot.whenReady((ReadyEvent event) {
        event.join("#irc.dart");
    });

    bot.command("help").listen((MessageEvent event) {
        event.reply("> ${Color.BLUE}Commands${Color.RESET}: ${bot.commands.keys.join(', ')}");
    });

    Client.debug(bot.client());

    bot.connect();
}
