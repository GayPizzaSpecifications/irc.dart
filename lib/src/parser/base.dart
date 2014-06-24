part of irc.parser;

abstract class IrcParser extends Converter<String, Message> {
  @override
  Message convert(String line);

  @override
  IrcParserSink startChunkedConversion(Sink<String> sink) {
    if (sink is! StringConversionSink) {
      sink = new StringConversionSink.from(sink);
    }
    return new IrcParserSink(this, sink);
  }
}

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

  @override
  void close() => super.close();
}