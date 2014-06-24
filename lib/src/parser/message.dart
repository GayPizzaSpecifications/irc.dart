part of irc.parser;

class Message {
  String line;
  String command;
  String message;
  String _hostmask;
  List<String> parameters;

  Message({this.line, hostmask, this.command, this.message, this.parameters}) : _hostmask = hostmask;

  @override
  String toString() => line;

  ParsedHostmask get hostmask {
    RegExp regex = new RegExp("[!@]");
    List<String> parts = _hostmask.split(regex);
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