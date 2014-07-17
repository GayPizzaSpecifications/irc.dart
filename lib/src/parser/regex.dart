part of irc.parser;

/**
 * Regular Expression based IRC Parser
 */
class RegexIrcParser extends IrcParser {
  /**
   * Basic Regular Expression for IRC Parsing.
   *
   * Expression: ^(?:[:](\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$
   */
  static final REGEX = new RegExp(r"^(?:[:](\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$");

  @override
  Message convert(String line) {
    List<String> match;
    {
      var parsed = REGEX.firstMatch(line);
      match = new List.generate(parsed.groupCount + 1, parsed.group);
    }
    var hostmask = match[1];
    var command = match[2];
    var param_string = match[3];
    var msg = match[4];
    var parameters = param_string != null ? param_string.split(" ") : [];
    return new Message(line: line, hostmask: hostmask, command: command, message: msg, parameters: parameters);
  }
}