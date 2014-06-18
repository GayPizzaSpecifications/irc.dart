part of irc.bot;

/**
 * Base Class for Bots
 */
abstract class Bot {
  Client client();

  void connect() => client().connect();

  void disconnect() => client().disconnect();

  Channel channel(String name) => client().channel(name);

  bool register(handler) => client().register(handler);

  void join(String channel) => client().join(channel);

  void part(String channel) => client().part(channel);

  void message(String target, String message) => client().message(target, message);
}