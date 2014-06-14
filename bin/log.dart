import "package:irc/irc.dart";
import "dart:io";

main() {
  BotConfig config = new BotConfig(host: "irc.esper.net", port: 6667, nickname: "DartLogBot", username: "DartLogBot");
  LogBot bot = new LogBot(config, Platform.environment["HOME"] + "/.irc_logs/");
  bot.channels.addAll([
    "#directcode"
  ]);
  bot.connect();
}