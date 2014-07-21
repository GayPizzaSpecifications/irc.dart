part of irc.parser;

/**
 * Base class for IRC Parsers
 *
 * ```
 * var parser = new SomeIrcParser();
 * var message = parser.convert(":some.server PRIVMSG #SomeChannel :Some Message");
 * // Use Message Instance
 * ```
 */
abstract class IrcParser extends Converter<String, Message> {
  
  /**
   * Creates the default parser [RegexIrcParser].
   */
  factory IrcParser() {
    return new RegexIrcParser();
  }
  
  /**
   * Parses [line] as an IRC line and outputs a [Message]
   */
  @override
  Message convert(String line);
}
