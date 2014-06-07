import '../lib/irc.dart';
import 'dart:io';

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

    bot.command("dart").listen((MessageEvent event) {
        event.reply("> Dart VM: ${Platform.version}");
    });

    bot.onMessage((MessageEvent event) {

    });

    Client.debug(bot.client());

    bot.connect();
}
