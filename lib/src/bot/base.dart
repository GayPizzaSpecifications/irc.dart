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
  Channel channel(String name) => client.channel(name);

  /**
   * Registers a Handler
   */
  bool register(handler) => client.register(handler);

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
  void message(String target, String message) => client.message(target, message);
}