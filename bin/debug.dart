import '../lib/irc.dart';
import 'dart:io';
import 'dart:mirrors';
import 'dart:collection';

void main() {

  BotConfig config = new BotConfig(host: "irc.esper.net", port: 6667, nickname: "DartBot", username: "DartBot", synchronous: true);

  CommandBot bot = new CommandBot(config, prefix: ".");

  bot
    ..on(Events.LineReceive).listen((LineReceiveEvent event) {
    print(">> ${event.message}");
  })

    ..on(Events.LineSent).listen((LineSentEvent event) {
    print("<< ${event.message}");
  })

    ..onMessage((MessageEvent event) => print("<${event.target}><${event.from}> ${event.message}"))

    ..whenReady((ReadyEvent event) {
    event.join("#directcode");
  })

    ..command("help").listen((CommandEvent event) {
    event.reply("> ${Color.BLUE}Commands${Color.RESET}: ${bot.commandNames().join(', ')}");
  })

    ..command("dart").listen((CommandEvent event) {
    event.reply("> Dart VM: ${Platform.version}");
  })

    ..command("ping").listen((CommandEvent event) {
    event.reply("> Pong!");
  })

    ..command("opall").listen((CommandEvent event) {
    event.args.forEach((it) => event.channel.op(it));
  })

    ..command("nick").listen((CommandEvent event) {
    bot.client().nickname(event.args[0]);
  })

    ..command("join").listen((CommandEvent event) {
    if (event.checkArguments(1, "> Usage: join <channel>")) {
      bot.join(event.args[0]);
    }
  })

    ..command("topic").listen((CommandEvent event) {
    event.reply("> ${event.channel.topic}");
  })

    ..command("list-libs").listen((CommandEvent event) {
    Set<String> libraries = [].toSet();
    currentMirrorSystem().libraries.forEach((key, value) {
      libraries.add(MirrorSystem.getName(value.simpleName));
    });
    event.reply("> Libraries: ${libraries.join(', ')}");
  })

    ..command("library").listen((CommandEvent event) {
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
  })

    ..command("part").listen((CommandEvent event) {
    if (event.checkArguments(1, "> Usage: part <channel>")) {
      bot.client().part(event.args[0]);
    }
  })

    ..command("quit").listen((CommandEvent event) {
    bot.disconnect();
  })

    ..onJoin((JoinEvent event) {
    print("<${event.channel.name}> ${event.user} has joined");
  })

    ..onBotJoin((BotJoinEvent event) {
    print("Joined ${event.channel.name}");
  })

    ..onBotPart((BotPartEvent event) {
    print("Left ${event.channel.name}");
  })

    ..on(Events.Part).listen((PartEvent event) {
    print("<${event.channel.name}> ${event.user} has left");
  })

    ..onLineSent((LineSentEvent event) {
    print("<< ${event.message}");
  })

    ..onLineReceived((LineReceiveEvent event) {
    print(">> ${event.message}");
  })

    ..connect();
}
