import '../lib/irc.dart';
import 'dart:io';

void main() {
  BotConfig config = new BotConfig(host: "irc.esper.net", port: 6667, nickname: "DartBot", username: "DartBot");

  CommandBot bot = new CommandBot(config, prefix: ".");

  bot.whenReady((ReadyEvent event) {
    event.join("#directcode");
  });

  bot.command("help").listen((CommandEvent event) {
    event.reply("> ${Color.BLUE}Commands${Color.RESET}: ${bot.commandNames().join(', ')}");
  });

  bot.command("dart").listen((CommandEvent event) {
    event.reply("> Dart VM: ${Platform.version}");
  });

  bot.onJoin((JoinEvent event) {
    if (event.isBot()) {
      print("Joined ${event.channel.name}");
    } else {
      print("<${event.channel.name}> ${event.user} has joined");
    }
  });

  bot.onMessage((MessageEvent event) => print("<${event.target}><${event.from}> ${event.message}"));

  bot.connect();
}
