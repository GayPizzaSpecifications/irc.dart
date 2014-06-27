part of irc.parser;

/**
 * Represents a Hostmask that has been parsed
 */
class Hostmask {
  static final HOSTMASK_REGEX = new RegExp("[!@]");

  /**
   * Nickname is Hostmask
   */
  String nickname;

  /**
   * User's Identity
   */
  String identity;

  /**
   * User's Hostname
   */
  String hostname;

  /**
   * Creates a Hostmask instance
   */
  Hostmask({this.nickname, this.identity, this.hostname});

  Hostmask.parse(String input) {
    var parts = input.split(HOSTMASK_REGEX);

    this.nickname = parts[0];
    this.identity = parts[1];
    this.hostname = parts[2];
  }
}

class GlobHostmask {
  String pattern;

  GlobHostmask(this.pattern);

  bool matches(String hostmask) => new Glob(pattern).hasMatch(hostmask);

  toString() => pattern;
}