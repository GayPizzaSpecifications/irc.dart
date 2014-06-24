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
   * Parameters
   */
  List<String> parameters;

  /**
   * Creates a new Message
   */
  Message({this.line, hostmask, this.command, this.message, this.parameters})
      : _hostmask = hostmask;

  @override
  String toString() => line;

  /**
   * Gets the Parsed Hostmask
   */
  ParsedHostmask get hostmask {
    var regex = new RegExp("[!@]");
    var parts = _hostmask.split(regex);
    return new ParsedHostmask(nickname: parts[0], identity: parts[1], hostname: parts[2]);
  }

  String get plain_hostmask => _hostmask;
}

class ParsedHostmask {
  String nickname;
  String identity;
  String hostname;

  ParsedHostmask({this.nickname, this.identity, this.hostname});
}