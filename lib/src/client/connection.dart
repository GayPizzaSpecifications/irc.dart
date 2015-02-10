part of irc.client;

abstract class IrcConnection {
  Future connect(Configuration config);
  Future disconnect();
  
  void send(String line);
  Stream<String> lines();
}

class SocketIrcConnection extends IrcConnection {
  Socket _socket;
  
  @override
  Future connect(Configuration config) {
    if (config.ssl) {
      return SecureSocket.connect(config.host, config.port, onBadCertificate: (cert) => config.allowInvalidCertificates).then((socket) {
        _socket = socket;
      });
    } else {
      return Socket.connect(config.host, config.port).then((socket) {
        _socket = socket;
      }); 
    }
  }
  
  @override
  Stream<String> lines() => _socket.transform(new Utf8Decoder(allowMalformed: true)).transform(new LineSplitter());

  @override
  Future disconnect() => _socket.close();

  @override
  void send(String line) => _socket.writeln(line);
}
