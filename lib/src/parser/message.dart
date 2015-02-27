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
  String get plainHostmask => _hostmask;

  bool get hasAccountTag => tags.containsKey("account");
  String get accountTag => tags["account"];
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
  static Map<String, dynamic> parseTags(String input) {
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
  
  /**
   * Parses the ISUPPORT PREFIX Property
   * 
   * [input] should begin with '(' and contain ')'
   */
  static Map<String, String> parseSupportedPrefixes(String input) {
    if (input == null) {
      return {};
    }

    var out = {};
    var split = input.split(")");
    var modes = split[0].substring(1).split("");
    var prefixes = split[1].split("");
    
    var i = 0;
    for (var mode in modes) {
      out[mode] = prefixes[i];
      i++;
    }
    
    return out;
  }

  static ModeChange parseMode(String input) {
    ModeChange mode;
    if (input.startsWith("+")) {
      mode = new ModeChange(input.substring(1).split(""), []);
    } else if (input.startsWith("-")) {
      mode = new ModeChange([], input.substring(1).split(""));
    } else {
      throw new Exception("Failed to parse mode: invalid prefix for ${input}");
    }
    return mode;
  }
}

class ModeChange {
  final List<String> added;
  final List<String> removed;

  List<String> get modes => isAdded ? added : removed;
  bool get isAdded => added.isNotEmpty;
  bool get isRemoved => removed.isNotEmpty;

  ModeChange(this.added, this.removed);

  @override
  String toString() => added.isEmpty ? "-${removed.join()}" : "+${added.join()}";
}

class Mode {
  final List<String> modes;

  Mode(this.modes);
  Mode.empty() : modes = [];

  bool has(String x) {
    return modes.contains(x);
  }
}
