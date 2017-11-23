part of irc.client;

abstract class IrcConnection {
  Future connect(Configuration config);
  Future disconnect();
  
  void send(String line);
  Stream<String> lines();
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
}
