part of irc.client;

/**
 * IRC Client Configuration
 */
class Configuration {
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
   * The address to bind the local socket to.
   */
  String bindHost;
  
  /**
   * Creates a new Client Configuration with default values.
   */
  Configuration({this.host: "irc.esper.net", this.port: 6667,
      this.nickname: "DartBot", this.username: "DartBot",
      this.realname: "Dart IRC Bot", this.ssl: false,
      this.allowInvalidCertificates: false,
      this.bindHost});
}
