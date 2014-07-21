part of irc.parser;

/**
 * IRC Message
 */
class Message {
  /**
   * Original Line
   */
  String line;

  /**
   * IRC Command
   */
  String command;

  /**
   * Message
   */
  String message;

  String _hostmask;

  /**
   * IRC v3 Tags
   */
  Map<String, String> tags;

  /**
   * Parameters
   */
  List<String> parameters;

  /**
   * Creates a new Message
   */
  Message({this.line, hostmask, this.command, this.message, this.parameters, this.tags})
      : _hostmask = hostmask;

  @override
  String toString() => line;

  /**
   * Gets the Parsed Hostmask
   */
  Hostmask get hostmask => new Hostmask.parse(_hostmask);

  /**
   * The Plain Hostmask
   */
  String get plain_hostmask => _hostmask;
}

/**
 * IRC Parser Helpers
 */
class IrcParserSupport {
  /**
   * Parses IRCv3 Tags from [input].
   * 
   * [input] should begin with the @ part of the tags
   * and not include the space at the end.
   */
  static Map<String, dynamic> parse_tags(String input) {
    var out = <String, dynamic>{};
    var parts = input.substring(1).split(";");
    for (var part in parts) {
      if (part.contains("=")) {
        var keyValue = part.split("=");
        out[keyValue[0]] = keyValue[1];
      } else {
        out[part] = true;
      }
    }
    return out;
  }
}
