part of irc.client;

/**
 * IRC Client Configuration
 */
class IrcConfig {
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
   * Enable SSl
   */
  bool ssl;
  
  /**
   * Allow Invalid SSL Certificates
   */
  bool allowInvalidCertificates;

  /**
   * Creates a new Client Configuration with default values.
   */
  IrcConfig({this.host: "irc.esper.net", this.port: 6667, this.nickname: "DartBot", this.username: "DartBot", this.realname: "Dart IRC Bot", this.ssl: false, this.allowInvalidCertificates: false});

  /**
   * Loads the Client Configuration from [map] using field names as keys
   */
  IrcConfig.fromMap(Map<String, Object> map) {
    host = map["host"];
    port = map["port"];
    nickname = map["nickname"];
    username = map["username"];
    realname = map["realname"];
  }

  /**
   * Loads the Client Configuration from the [input] as JSON using field names as keys
   */
  IrcConfig.fromJSON(String input)
      : this.fromMap(JSON.decode(input));
}
