part of irc;

/**
 * Control Multiple Clients
 */
class ClientPool {
  /**
   * All Clients
   */
  List<Client> clients;

  /**
   * Adds a Client using the [config]
   */
  int addClient(BotConfig config) {
    var client = new Client(config);
    clients.add(client);
    return clients.indexOf(client);
  }

  void connectAll() => forEach((client) => client.connect());
  void disconnectAll([String reason = null, bool force = false]) => forEach((client) => client.disconnect(reason: reason, force: force));
  void message(String target, String message) => forEach((client) => client.message(target, message));
  void register(handler) => forEach((client) => client.register(handler));
  void forEach(void action(Client client)) => clients.forEach(action);
}
