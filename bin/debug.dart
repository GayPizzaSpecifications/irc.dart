import '../lib/irc.dart';
import 'dart:io';
import 'dart:mirrors';
import 'dart:collection';

void main() {

  BotConfig config = new BotConfig(host: "irc.esper.net", port: 6667, nickname: "DartBot", username: "DartBot", synchronous: true);

  CommandBot bot = new CommandBot(config, prefix: ".");

  bot.on(Events.Line).listen((LineReceiveEvent event) {
    print(">> ${event.message}");
  });

  bot.on(Events.Send).listen((LineSentEvent event) {
    print("<< ${event.message}");
  });

  bot.onMessage((MessageEvent event) => print("<${event.target}><${event.from}> ${event.message}"));

  bot.whenReady((ReadyEvent event) {
    event.join("#directcode");
  });

  bot.command("help").listen((CommandEvent event) {
    event.reply("> ${Color.BLUE}Commands${Color.RESET}: ${bot.commandNames().join(', ')}");
  });

  bot.command("dart").listen((CommandEvent event) {
    event.reply("> Dart VM: ${Platform.version}");
  });

  bot.command("ping").listen((CommandEvent event) {
    event.reply("> Pong!");
  });

  bot.command("opall").listen((CommandEvent event) {
    event.args.forEach((it) => bot.client().send("MODE ${event.channel.name} +o ${it}"));
  });

  bot.command("nick").listen((CommandEvent event) {
    bot.client().nickname(event.args[0]);
  });

  bot.command("join").listen((CommandEvent event) {
    if (event.checkArguments(1, "> Usage: join <channel>")) {
      bot.join(event.args[0]);
    }
  });

  bot.command("list-libs").listen((CommandEvent event) {
    Set<String> libraries = [].toSet();
    currentMirrorSystem().libraries.forEach((key, value) {
      libraries.add(MirrorSystem.getName(value.simpleName));
    });
    event.reply("> Libraries: ${libraries.join(', ')}");
  });

  bot.command("library").listen((CommandEvent event) {
    if (event.checkArguments(1, "> Usage: library <name>")) {
      String libName = event.args[0];
      try {
        LibraryMirror mirror = currentMirrorSystem().findLibrary(MirrorSystem.getSymbol(libName));
        event.reply("> Declarations: ${mirror.declarations.keys.join(', ')}");
        event.reply("> Location: ${mirror.uri}");
      } catch(e) {
        event.reply("> No Such Library: ${libName}");
      }
    }
  });

  bot.command("part").listen((CommandEvent event) {
    if (event.checkArguments(1, "> Usage: part <channel>")) {
      bot.client().part(event.args[0]);
    }
  });

  bot.command("quit").listen((CommandEvent event) {
    bot.disconnect();
  });

  bot.onJoin((JoinEvent event) {
    print("<${event.channel.name}> ${event.user} has joined");
  });

  bot.onBotJoin((BotJoinEvent event) {
    print("Joined ${event.channel.name}");
  });

  bot.onBotPart((BotPartEvent event) {
    print("Left ${event.channel.name}");
  });

  bot.on(Events.Part).listen((PartEvent event) {
    print("<${event.channel.name}> ${event.user} has left");
  });

  bot.onLineReceived((LineReceiveEvent event) {
    print(">> ${event.message}");
  });

  bot.onLineSent((LineSentEvent event) {
    print("<< ${event.message}");
  });

  bot.connect();
}
