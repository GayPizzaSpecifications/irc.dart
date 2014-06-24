part of irc.parser;

abstract class IRCParser extends Converter<String, Message> {
  @override
  Message convert(String line);

  @override
  IRCParserSink startChunkedConversion(Sink<String> sink) {
    if (sink is! StringConversionSink) {
      sink = new StringConversionSink.from(sink);
    }
    return new IRCParserSink(this, sink);
  }
}

class IRCParserSink extends StringConversionSinkBase {
  final IRCParser _converter;
  final StringConversionSink _sink;

  IRCParserSink(this._converter, this._sink);

  @override
  void addSlice(String chunk, int start, int end, bool isLast) {
    var result = this._converter.convert(chunk);

    _sink.add(result);
    if (isLast)
      _sink.close();
  }
}