part of irc.client;

abstract class IrcConnection {
  Future connect(Configuration config);
  Future disconnect();
  
  void send(String line);
  Stream<String> lines();

  Future initiateTlsConnection(Configuration config) async {}
}

class SocketIrcConnection extends IrcConnection {
  Stream<String> _lines;
  Socket _socket;
  bool _done = false;

  List<String> _queue = <String>[];
  
  @override
  Future connect(Configuration config) async {
    var socket = await Socket.connect(
      config.host,
      config.port,
      sourceAddress: config.bindHost
    );
    
    if (config.ssl) {
      socket = await SecureSocket.secure(
        socket,
        onBadCertificate: (cert) {
          if (config.allowInvalidCertificates) {
            return true;
          }
          return false;
        }
      );
    }
    
    _socket = socket;

    _done = false;
    _socket.done.then((_) {
      _done = true;
    });
    return socket;
  }
  
  @override
  Stream<String> lines() {
    if (_lines == null) {
      _lines = _socket
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter());
    }
    
    return _lines;
  }

  @override
  Future disconnect() async {
    if (_done) {
      return new Future.value();
    }
    _lines = null;
    var future = _socket.close();
    _socket.destroy();
    _done = true;
    return future;
  }

  @override
  void send(String line) {
    if (!_done) {
      _socket.writeln(line);
    }
  }

  @override
  Future initiateTlsConnection(Configuration config) async {
    _socket = await SecureSocket.secure(
      _socket,
      onBadCertificate: (cert) {
        if (config.allowInvalidCertificates) {
          return true;
        }
        return false;
      }
    );

    _lines = null;

    _done = false;
    _socket.done.then((_) {
      _done = true;
    });
  }
}

class WebSocketIrcConnection extends IrcConnection {
  WebSocket _socket;

  @override
  Future connect(Configuration config) async {
    var uri = new Uri(
      scheme: config.ssl ? "wss" : "ws",
      port: config.port,
      host: config.host,
      path: config.websocketPath
    );

    _socket = await WebSocket.connect(uri.toString());
  }

  @override
  Future disconnect() async {
    await _socket.close(WebSocketStatus.normalClosure, "IRC disconnect.");
  }

  @override
  Stream<String> lines() {
    return _socket.where((e) => e is String).cast<String>().map((String line) {
      return line.substring(0, line.length - 2);
    });
  }

  @override
  void send(String line) {
    _socket.add("${line}\r\n");
  }
}
