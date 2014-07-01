part of irc;

class ClientPool {
  List<Client> clients;
  
  int addClient(BotConfig config) {
    var client = new Client(config);
    clients.add(client);
    return clients.indexOf(client);
  }
  
  void connectAll() => clients.forEach((client) => client.connect());
  
  void disconnectAll([String reason = null, bool force = false]) => clients.forEach((client) => client.disconnect(reason: reason, force: force));

  void message(String target, String message) {
    clients.forEach((client) {
      client.message(target, message);
    });
  }
  
  void register(handler) {
    clients.forEach((client) {
      client.register(handler);
    });
  }
}