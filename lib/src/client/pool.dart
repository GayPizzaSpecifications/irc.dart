part of irc.client;

/**
 * Control Multiple Clients
 */
class ClientPool {
  /**
   * All Clients
   */
  List<Client> clients = [];

  /**
   * Adds a Client using the [config].
   */
  int addClient(IrcConfig config, {bool connect: false}) {
    var client = new Client(config);
    clients.add(client);
    if (connect) {
      client.connect();
    }
    return clients.indexOf(client);
  }
  
  Client clientAt(int position) => clients[position];
  
  int idOf(Client client) => clients.indexOf(client);
  
  Client operator [](int id) => clientAt(id);

  void connectAll() => forEach((client) => client.connect());
  void disconnectAll([String reason = null]) => forEach((client) => client.disconnect(reason: reason));
  void message(String target, String message) => forEach((client) => client.sendMessage(target, message));
  void register(handler) => forEach((client) => client.register(handler));
  void forEach(void action(Client client)) => clients.forEach(action);
}
