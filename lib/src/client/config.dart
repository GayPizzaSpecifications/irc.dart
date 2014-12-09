part of irc.client;

/**
 * Bot (Client) Configuration
 */
class BotConfig {
  /**
   * Server Host
   */
  String host;

  /**
   * Server Port
   */
  int port;

  /**
   * Client Nickname
   */
  String nickname;

  /**
   * Client Real Name
   */
  String realname;

  /**
   * Client Username
   */
  String username;

  /**
   * Creates a new Client Configuration with default values.
   */
  BotConfig({this.host: "irc.esper.net", this.port: 6667, this.nickname: "DartBot", this.username: "DartBot", this.realname: "Dart IRC Bot"});

  /**
   * Loads the Client Configuration from [map] using field names as keys
   */
  BotConfig.fromMap(Map<String, Object> map) {
    host = map["host"];
    port = map["port"];
    nickname = map["nickname"];
    username = map["username"];
    realname = map["realname"];
  }

  /**
   * Loads the Client Configuration from the [input] as JSON using field names as keys
   */
  BotConfig.fromJSON(String input)
      : this.fromMap(JSON.decode(input));
}
