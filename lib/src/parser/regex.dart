part of irc.parser;

/// Regular Expression based IRC Parser
class RegexIrcParser extends IrcParser {
  /// Basic Regular Expression for IRC Parsing.
  static final kLinePattern = RegExp(
      r'^(?:@([^\r\n ]*) +|())(?::([^\r\n ]+) +|())([^\r\n ]+)(?: +([^:\r\n ]+[^\r\n ]*(?: +[^:\r\n ]+[^\r\n ]*)*)|())?(?: +:([^\r\n]*)| +())?[\r\n]*$');

  @override
  Message convert(String line) {
    line = line.trimLeft();
    List<String> match;
    {
      var parsed = kLinePattern.firstMatch(line);

      if (parsed == null) {
        return null;
      }

      match = List<String>.generate(parsed.groupCount + 1, parsed.group);
    }

    var tagStuff = match[1];
    var hostmask = match[3];
    var command = match[5];
    var param = match[6];
    var msg = match[8];
    var parameters = param != null ? param.split(' ') : <String>[];
    var tags = <String, String>{};

    if (tagStuff != null && tagStuff.isNotEmpty) {
      tags = IrcParserSupport.parseTags(tagStuff);
    }

    return Message(
        line: line,
        hostmask: hostmask,
        command: command,
        message: msg,
        parameters: parameters,
        tags: tags);
  }
}
