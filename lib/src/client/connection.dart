part of irc.client;

abstract class IrcConnection {
  Future connect(IrcConfig config);
  Future disconnect();
  
  void send(String line);
  Stream<String> lines();
}

class SocketIrcConnection extends IrcConnection {
  Socket _socket;
  
  @override
  Future connect(IrcConfig config) {
    return Socket.connect(config.host, config.port).then((socket) {
      _socket = socket;
    });
  }
  
  @override
  Stream<String> lines() => _socket.transform(UTF8.decoder).transform(new LineSplitter());

  @override
  Future disconnect() => _socket.close();

  @override
  void send(String line) => _socket.writeln(line);
}