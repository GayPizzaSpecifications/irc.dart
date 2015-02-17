import "package:irc/client.dart";

void main() {
  var config = new Configuration(host: "irc.esper.net", port: 6667, nickname: "DartBot", username: "DartBot");
  var bot = new CommandBot(config, prefix: ".");

  bot.onEvent(MOTDEvent).listen((event) {
    print(event.message);
  });
  
  bot.onReady.listen((event) {
    event.join("#directcode");
  });
  
  bot.onMessage.listen((event) {
    print("<${event.target}><${event.from}> ${event.message}");
  });
  
  bot.command("help", (CommandEvent event) {
    event.reply("> ${Color.BLUE}Commands${Color.RESET}: ${bot.commandNames().join(', ')}");
  });

  bot.onBotJoin.listen((event) {
    print("Joined ${event.channel.name}");
  });

  bot.onBotPart.listen((event) {
    print("Left ${event.channel.name}");
  });

  bot.connect();
}
