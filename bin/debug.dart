import '../lib/irc.dart';
import 'dart:io';
import 'dart:mirrors';
import 'dart:collection';

void main() {

  BotConfig config = new BotConfig(host: "irc.esper.net", port: 6667, nickname: "DartBot", username: "DartBot", synchronous: true);

  CommandBot bot = new CommandBot(config, prefix: ".");

  bot.on(Events.Line).listen((LineEvent event) {
    print(">> ${event.message}");
  });

  bot.on(Events.Send).listen((SendEvent event) {
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
    if (event.isBot()) {
      print("Joined ${event.channel.name}");
    } else {
      print("<${event.channel.name}> ${event.user} has joined");
    }
  });

  bot.on(Events.Part).listen((PartEvent event) {
    print("<${event.channel.name}> ${event.user} has left");
  });

  bot.client().on(Events.Line).listen((LineEvent event) {
    print(">> ${event.message}");
  });

  bot.client().on(Events.Send).listen((SendEvent event) {
    print("<< ${event.message}");
  });

  bot.connect();
}
