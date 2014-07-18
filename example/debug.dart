import 'package:irc/irc.dart';
import 'dart:io';
import 'dart:mirrors';
import 'dart:convert';

void main() {

  var config = new BotConfig(host: "irc.esper.net", port: 6667, nickname: "DartBot", username: "DartBot");

  var bot = new CommandBot(config, prefix: "?");

  var configFile = new File("${Platform.environment["HOME"]}/.irc_debug.json");

  var conf = <String, String>{};

  if (configFile.existsSync()) {
    conf = JSON.decode(configFile.readAsStringSync());
  }

  bot
      ..register((LineReceiveEvent event) {
        print(">> ${event.line}");
      })

      ..register((LineSentEvent event) {
        print("<< ${event.line}");
      })

      ..register((MessageEvent event) => print("<${event.target}><${event.from}> ${event.message}"))

      ..register((ReadyEvent event) {
        if (conf.containsKey("identityPassword")) bot.client.identify(username: conf["identityUsername"], password: conf["identityPassword"]);
        event.join("#directcode");
      })

      ..command("help").listen((CommandEvent event) {
        event.reply("> ${Color.BLUE}Commands${Color.RESET}: ${bot.commandNames().join(', ')}");
      })

      ..command("dart").listen((CommandEvent event) {
        event.reply("> Dart VM: ${Platform.version}");
      })

      ..command("ping").listen((CommandEvent event) {
        event.client.send("PING :cmd_${event.channel.name}");
      })

      ..register((PongEvent event) {
        if (event.message.startsWith("cmd_")) {
          event.client.message(event.message.replaceFirst("cmd_", ""), "> PONG!");
        }
      })

      ..command("opall").listen((CommandEvent event) {
        event.args.forEach((it) => event.channel.op(it));
      })

      ..command("nick").listen((CommandEvent event) {
        bot.client.changeNickname(event.args[0]);
      })

      ..command("join").listen((CommandEvent event) {
        if (event.checkArguments(1, "> Usage: join <channel>")) {
          bot.join(event.args[0]);
        }
      })

      ..command("topic").listen((CommandEvent event) {
        event.reply("> ${event.channel.topic}");
      })

      ..command("bans").listen((CommandEvent event) {
        event.reply("> ${event.channel.bans}");
      })

      ..command("raw").listen((CommandEvent event) {
        bot.client.send(event.args.join(" "));
      })

      ..command("list-libs").listen((CommandEvent event) {
        Set<String> libraries = [].toSet();
        currentMirrorSystem().libraries.forEach((key, value) {
          libraries.add(MirrorSystem.getName(value.qualifiedName));
        });
        event.reply("> Libraries: ${libraries.join(', ')}");
      })

      ..command("list-users").listen((CommandEvent event) {
        var reply = (msg) => bot.client.notice(event.from, msg);
        reply("> Members: ${event.channel.members.join(", ")}");
        reply("> Ops: ${event.channel.ops.join(", ")}");
        reply("> Voices: ${event.channel.voices.join(", ")}");
      })

      ..command("library").listen((CommandEvent event) {
        if (event.checkArguments(1, "> Usage: library <name>")) {
          String libName = event.args[0];
          try {
            LibraryMirror mirror = currentMirrorSystem().findLibrary(MirrorSystem.getSymbol(libName));
            event.reply("> Declarations: ${mirror.declarations.keys.join(', ')}");
            event.reply("> Location: ${mirror.uri}");
          } catch (e) {
            event.reply("> No Such Library: ${libName}");
          }
        }
      })

      ..command("part").listen((CommandEvent event) {
        if (event.checkArguments(1, "> Usage: part <channel>")) {
          bot.client.part(event.args[0]);
        }
      })

      ..command("quit").listen((CommandEvent event) {
        bot.disconnect();
      })

      ..register((JoinEvent event) {
        print("<${event.channel.name}> ${event.user} has joined");
      })

      ..register((BotJoinEvent event) {
        print("Joined ${event.channel.name}");
      })

      ..register((BotPartEvent event) {
        print("Left ${event.channel.name}");
      })

      ..register((NickChangeEvent event) {
        print("${event.original} changed their nick to ${event.now}");
      })

      ..register((PartEvent event) {
        print("<${event.channel.name}> ${event.user} has left");
      })

      ..register((KickEvent event) {
        if (event.user == event.client.nickname) {
          event.client.join(event.channel.name);
        }
      })

      ..register((ErrorEvent event) {
        print("-------------------------------------------------------------------");
        switch (event.type) {
          case "socket":
            print(event.err);
            print(event.err.stackTrace);
            break;
          case "server":
            print("Server Error: ${event.message}");
            break;
          case "socket-zone":
            print(event.err);
            print(event.err.stackTrace);
            break;
          default:
            print("Error Type: ${event.type}");
            print("Message: ${event.message}");
            print("Error: ${event.err}");
            break;
        }
        print("-------------------------------------------------------------------");
        exit(1);
      })

      ..connect();
}
