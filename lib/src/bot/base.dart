part of irc.bot;

/**
 * Base Class for Bots
 */
abstract class Bot {
  /**
   * Gets the Client
   */
  Client get client;

  /**
   * Connects the Bot
   */
  void connect() => client.connect();

  /**
   * Disconnects the Bot
   */
  Future disconnect() => client.disconnect();

  /**
   * Gets a Channel
   */
  Channel getChannel(String name) => client.getChannel(name);

  /**
   * Registers a Handler
   */
  bool register(handler) => client.register(handler);
  
  /**
   * Registers a Handler or Behavior
   */
  bool apply(handler) => register(handler);

  /**
   * Joins a Channel
   */
  void join(String channel) => client.join(channel);

  /**
   * Parts a Channel
   */
  void part(String channel) => client.part(channel);

  /**
   * Sends a Message
   */
  void sendMessage(String target, String message) => client.sendMessage(target, message);
}

typedef void EventHandler<T>(T event);
