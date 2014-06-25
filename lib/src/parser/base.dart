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
   * Parses [line] as an IRC line and outputs a [Message]
   */
  @override
  Message convert(String line);

  /**
   * Provides support for chunked parsing
   */
  @override
  IrcParserSink startChunkedConversion(Sink<String> sink) {
    if (sink is! StringConversionSink) {
      sink = new StringConversionSink.from(sink);
    }
    return new IrcParserSink(this, sink);
  }
}

/**
 * Sink Implementation for IRC Parsers
 */
class IrcParserSink extends StringConversionSinkBase {
  final IrcParser _converter;
  final StringConversionSink _sink;

  IrcParserSink(this._converter, this._sink);

  @override
  void addSlice(String chunk, int start, int end, bool isLast) {
    var result = this._converter.convert(chunk);
    _sink.add(result);
    if (isLast)
      _sink.close();
  }

  /**
   * Closes the Sink
   */
  @override
  void close() => super.close();
}