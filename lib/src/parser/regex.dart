part of irc.parser;

class RegexIrcParser extends IrcParser {
  static final RegExp REGEX = new RegExp(r"^(?:[:](\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$");

  @override
  Message convert(String line) {
    List<String> match = new List<String>(5);
    {
      Match parsed = REGEX.firstMatch(line);
      for (int i = 0; i <= parsed.groupCount; i++)
        match[i] = parsed.group(i);
    }
    var hostmask = match[1];
    var command = match[2];
    var param_string = match[3];
    var msg = match[4];
    var parameters = param_string != null ? param_string.split(" ") : [];
    return new Message(line: line, hostmask: hostmask, command: command, message: msg, parameters: parameters);
  }
}