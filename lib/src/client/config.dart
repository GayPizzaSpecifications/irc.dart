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
   * Server Password
   */
  String password;

  /**
   * Enable SSl
   */
  bool ssl;

  /**
   * Allow Invalid SSL Certificates
   */
  bool allowInvalidCertificates;

  /**
   * Enables Invite Notifier
   */
  bool enableInviteNotify;

  /**
   * Enables Extended Join
   */
  bool enableExtendedJoin;

  /**
   * Enables Self Message Handling
   */
  bool enableSelfMessage;

  /**
   * Enables Account Tags
   */
  bool enableAccountTag;

  /**
   * Enables Multi Prefix
   */
  bool enableMultiPrefix;

  /**
   * Enables Message Intents
   */
  bool enableMessageIntents;

  /**
   * Enables Away Notify
   */
  bool enableAwayNotify;

  /**
   * Enable Capability Negotiation
   */
  bool enableCapabilityNegotiation;

  /**
   * The address to bind the local socket to.
   */
  String bindHost;

  /**
   * Capabilities to Request
   */
  List<String> capabilities;
  
  /**
   * Creates a new Client Configuration with default values.
   */
  Configuration({this.host: "irc.esper.net", this.port: 6667,
      this.nickname: "DartBot", this.username: "DartBot",
      this.realname: "Dart IRC Bot", this.ssl: false,
      this.allowInvalidCertificates: false,
      this.bindHost, this.password, this.capabilities: const [],
      this.enableInviteNotify: true, this.enableExtendedJoin: true,
      this.enableSelfMessage: true, this.enableAccountTag: true,
      this.enableMultiPrefix: true, this.enableCapabilityNegotiation: true,
      this.enableMessageIntents: true, this.enableAwayNotify: true});
}
