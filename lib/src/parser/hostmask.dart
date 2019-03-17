part of irc.parser;

/// Represents a Hostmask that has been parsed
class Hostmask {
  static final HOSTMASK_REGEX = new RegExp("[!@]");

  /// User's Nickname
  String nickname;

  /// User's Identity
  String identity;

  /// User's Hostname
  String hostname;

  /// Creates a Hostmask instance
  Hostmask({this.nickname, this.identity, this.hostname});

  /// Creates a Hostmask from the parsed [input].
  Hostmask.parse(String input) {
    var parts = input.split(HOSTMASK_REGEX);

    if (parts.length == 1) {
      hostname = input;
    } else {
      this.nickname = parts[0];
      this.identity = parts[1];
      this.hostname = parts[2];
    }
  }
}

/// A Hostmask Pattern
///
/// This is generally used for Ban Lists
class GlobHostmask {
  /// Hostmask Pattern
  String pattern;

  /// Creates a new Hostmask Pattern
  ///
  /// [pattern] is the glob pattern
  GlobHostmask(this.pattern);

  /// Checks if [hostmask] matches [pattern]
  bool matches(String hostmask) => new Glob(pattern).matches(hostmask);

  /// Gives a String Representation of this hostmask pattern
  @override
  String toString() => pattern;
}
