import "package:irc/client.dart";
import "dart:io";

main() {
  var config = new Configuration(host: "irc.esper.net", port: 6667, nickname: "DartLogBot", username: "DartLogBot");
  var bot = new LogBot(config, Platform.environment["HOME"] + "/.irc_logs/");
  bot.channels.addAll(["#directcode"]);
  bot.connect();
}
