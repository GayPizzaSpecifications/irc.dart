import 'package:irc/irc.dart';
import 'dart:io';

void main() {
  var config = new BotConfig(host: "irc.esper.net", port: 6667, nickname: "DartBot", username: "DartBot");

  var bot = new CommandBot(config, prefix: ".");

  bot.register((ReadyEvent event) {
    event.join("#directcode");
  });

  bot.command("help", (CommandEvent event) {
    event.reply("> ${Color.BLUE}Commands${Color.RESET}: ${bot.commandNames().join(', ')}");
  });

  bot.command("dart", (CommandEvent event) {
    event.reply("> Dart VM: ${Platform.version}");
  });

  bot.register((BotJoinEvent event) {
    print("Joined ${event.channel.name}");
  });

  bot.register((BotPartEvent event) {
    print("Left ${event.channel.name}");
  });

  bot.register((MessageEvent event) => print("<${event.target}><${event.from}> ${event.message}"));

  bot.connect();
}
