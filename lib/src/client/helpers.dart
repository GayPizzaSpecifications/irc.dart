part of irc.client;

class ParsedCommand {
  static ParsedCommand parsePotentialCommand(String prefix, MessageEvent event) {
    if (!event.message.startsWith(prefix)) {
      return null;
    }

    var command = event.message.substring(prefix.length);
    var args = <String>[];

    if (command.contains(" ")) {
      var real = command;
      command = command.substring(0, real.indexOf(' '));
      args.addAll(real.substring(command.length + 1).trim().split(" "));
    }

    return new ParsedCommand(event, command, args);
  }

  final MessageEvent event;
  final String command;
  final List<String> args;

  ParsedCommand(this.event, this.command, this.args);

  String asFullString(int start) => args.sublist(start).join(" ");
}
