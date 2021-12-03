part of irc.client;

/// IRC Client Configuration
class Configuration {
  /// Server Host
  String host;

  /// Server Port
  int port;

  /// Client Nickname
  String nickname;

  /// Client Real Name
  String realname;

  /// Client Username
  String username;

  /// Server Password
  String? password;

  /// Enable SSL
  bool ssl;

  /// Enable WebSocket connection support.
  bool websocket;

  /// The path of the websocket.
  String websocketPath = '/';

  /// Allow Invalid SSL Certificates
  bool allowInvalidCertificates;

  /// Enables the Invite Notifier IRCv3 extension
  bool enableInviteNotify;

  /// Enables the Extended Join IRCv3 extension
  bool enableExtendedJoin;

  /// Enables the Self Message IRCv3 extension
  bool enableSelfMessage;

  /// Enables the Account Tags IRCv3 extension
  bool enableAccountTag;

  /// Enables the Multi Prefix IRCv3 extension
  bool enableMultiPrefix;

  /// Enables the Message Intents IRCv3 extension
  bool enableMessageIntents;

  /// Enables the Away Notify IRCv3 extension
  bool enableAwayNotify;

  /// Enables the Server Time IRCv3 extension
  bool enableServerTime;

  /// Enables the Account Notify IRCv3 extension
  bool enableAccountNotify;

  /// Enable Capability Negotiation
  ///
  /// If this is enabled, all the IRCv3 extensions that are listed in [Configuration]
  /// and are set to true are requested, if the server has it.
  bool enableCapabilityNegotiation;

  /// Enables the UserHost in Names IRCv3 extension
  bool enableUserHostInNames;

  /// Enables the Change Host IRCv3 extension
  bool enableChangeHost;

  /// Enables the STARTTLS IRCv3 extension
  bool enableStartTls;

  /// Enables the Event Batching IRCv3 extension
  bool enableBatch;

  /// The address to bind the local socket to.
  String? bindHost;

  /// Extra IRCv3 Capabilities to Request
  List<String> capabilities;

  /// Enables Message Splitting
  bool enableMessageSplitting;

  /// Creates a new Client Configuration with default values.
  Configuration(
      {this.host = 'irc.esper.net',
      this.port = 6667,
      this.nickname = 'DartBot',
      this.username = 'DartBot',
      this.realname = 'Dart IRC Bot',
      this.ssl = false,
      this.allowInvalidCertificates = false,
      this.bindHost,
      this.password,
      this.capabilities = const [],
      this.enableInviteNotify = true,
      this.enableExtendedJoin = true,
      this.enableSelfMessage = true,
      this.enableAccountTag = true,
      this.enableMultiPrefix = true,
      this.enableCapabilityNegotiation = false,
      this.enableMessageIntents = true,
      this.enableAwayNotify = true,
      this.enableServerTime = true,
      this.enableAccountNotify = true,
      this.enableChangeHost = true,
      this.enableUserHostInNames = true,
      this.enableBatch = true,
      this.enableMessageSplitting = true,
      this.enableStartTls = false,
      this.websocket = false,
      this.websocketPath = '/'});
}
