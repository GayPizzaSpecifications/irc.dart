import 'irc.dart';

import "dart:io";

void main() {
    CommandBot bot = new CommandBot(new BotConfig(), prefix: "\$");

    bot.ready((ReadyEvent event) {
        event.join("#DirectCode");
    });

    bot.command("help").listen((MessageEvent event) {
        event.reply("> ${Color.BLUE}Commands${Color.RESET}: ${bot.commands.keys.join(', ')}");
    });

    IRCClient.debug(bot.client());

    bot.connect();
}
