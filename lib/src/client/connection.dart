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
  
  @override
  Future connect(Configuration config) async {
    var socket = await Socket.connect(config.host, config.port, sourceAddress: config.bindHost);
    
    if (config.ssl) {
      socket = await SecureSocket.secure(socket);
    }
    
    _socket = socket;
    
    return socket;
  }
  
  @override
  Stream<String> lines() {
    if (_lines == null) {
      _lines = _socket.transform(new Utf8Decoder(allowMalformed: true)).transform(new LineSplitter()).asBroadcastStream();
    }
    
    return _lines;
  }

  @override
  Future disconnect() async {
    _lines = null;
    return _socket.close();
  }

  @override
  void send(String line) => _socket.writeln(line);
}
