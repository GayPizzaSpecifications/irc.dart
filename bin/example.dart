import '../lib/irc.dart';

void main() {
    BotConfig config = new BotConfig(host: "irc.esper.net",
        port: 6667,
        nickname: "DartBot",
        username: "DartBot"
    );

    CommandBot bot = new CommandBot(config, prefix: ".");

    bot.whenReady((ReadyEvent event) {
        event.join("#directcode");
    });

    bot.command("help").listen((MessageEvent event) {
        event.reply("> ${Color.BLUE}Commands${Color.RESET}: ${bot.commands.keys.join(', ')}");
    });

    Client.debug(bot.client());

    bot.connect();
}
