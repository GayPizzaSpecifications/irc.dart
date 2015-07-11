part of irc.client;

/**
 * Base Class for a Client
 */
abstract class ClientBase {

  /**
   * The IRC Parser to use.
   */
  IrcParser get parser;

  /**
   * Client Configuration
   */
  Configuration get config;

  /**
   * The Client's nickname
   */
  String get nickname;

  /**
   * Get the Channels the Client is in
   */
  Iterable<Channel> get channels;

  /**
   * Get the Users the Client's channels contain
   */
  Iterable<User> get users;

  /**
   * Gets the Server's MOTD
   * Not Ready until the ReadyEvent is posted
   */
  String get motd;

  /**
   * Flag for if the Client is connected.
   */
  bool get connected;

  /**
   * Provides information about what the server supports.
   */
  Map<String, dynamic> get supported;

  /**
   * Sends the [message] to the [target] as a message.
   *
   *      client.message("ExampleUser", "Hello World");
   *
   * Note that this handles long messages. If the length of the message is 454
   * characters or bigger, it will split it up into multiple messages
   */
  void sendMessage(String target, String message) {
    var begin = "PRIVMSG ${target} :";

    var all = _handleMessageSending(begin, message);

    for (String msg in all) {
      send(begin + msg);
    }
  }

  /**
   * Changes the Client's Nickname
   *
   * [nickname] is the nickname to change to
   */
  void changeNickname(String nickname) {
    if (supported.containsKey("MAXNICKLEN") || supported.containsKey("NICKLEN")) {
      var max = supported.containsKey("MAXNICKLEN") ? supported["MAXNICKLEN"] : supported["NICKLEN"];

      if (nickname.length > max) {
        throw new ArgumentError("Nickname is too big for the server.");
      }
    }

    send("NICK ${nickname}");
  }

  /**
   * Splits the Messages if required.
   *
   * [begin] is the very beginning of the line (like 'PRIVMSG user :')
   * [input] is the message
   */
  List<String> _handleMessageSending(String begin, String input) {
    var all = [];
    if ((input.length + begin.length) > 454) {
      var max = 454 - (begin.length + 1);
      var chars = input.split("");
      var list = chars;
      while (list.isNotEmpty) {
        all.add(list.take(max).join());
        list = list.skip(max).toList();
      }
    } else {
      all = [input];
    }
    return all;
  }

  /**
   * Sends the [input] to the [target] as a notice
   *
   *      client.notice("ExampleUser", "Hello World");
   *
   * Note that this handles long messages. If the length of the message is 454
   * characters or bigger, it will split it up into multiple messages
   */
  void sendNotice(String target, String message) {
    var begin = "NOTICE ${target} :";
    var all = _handleMessageSending(begin, message);
    for (String msg in all) {
      send(begin + msg);
    }
  }

  /**
   * Identifies the user with the [nickserv].
   *
   * the default [username] is your configured username.
   * the default [password] is password.
   * the default [nickserv] is NickServ.
   */
  void identify({String username: "PLEASE_INJECT_DEFAULT", String password: "password", String nickserv: "NickServ", String generateMessage(String user, String password): _nickserv}) {
    if (username == "PLEASE_INJECT_DEFAULT") {
      username = config.username;
    }

    sendMessage(nickserv, _nickserv(username, password));
  }

  static String _nickserv(String username, String password) => "identify ${username} ${password}";

  /**
   * Sends [line] to the server
   *
   *      client.send("WHOIS ExampleUser");
   *
   * Will throw an error if [line] is greater than 510 characters
   */
  void send(String line);

  /**
   * Gets a Channel object for the channel's [name].
   * Returns null if no such channel exists.
   */
  Channel getChannel(String name);

  /**
   * Get a User object for the server.
   * Returns null if no such user exists.
   */
  User getUser(String nickname);

  /**
   * Joins the specified [channel].
   */
  void join(String channel) {
    if (supported.containsKey("CHANNELLEN")) {
      var max = supported["CHANNELLEN"];
      if (channel.length > max) {
        throw new ArgumentError.value(channel, "length is >${max}, which is the maximum channel name length set by the server.");
      }
    }
    send("JOIN ${channel}");
  }

  /**
   * Parts the specified [channel].
   */
  void part(String channel) {
    if (supported.containsKey("CHANNELLEN")) {
      var max = supported["CHANNELLEN"];
      if (channel.length > max) {
        throw new ArgumentError.value(channel, "length is >${max}, which is the maximum channel name length set by the server.");
      }
    }
    send("PART ${channel}");
  }

  /**
   * Disconnects the Client with the specified [reason].
   * If [force] is true, then the socket is forcibly closed.
   * When it is forcibly closed, a future is returned.
   */
  Future disconnect({String reason: "Client Disconnecting"});

  /**
   * Connects to the IRC Server
   * Any errors are sent through the [ErrorEvent].
   */
  void connect();

  /**
   * Posts a Event to the Event Dispatching System
   * The purpose of this method was to assist in checking for Error Events.
   *
   * [event] is the event to post.
   */
  void post(Event event);

  /**
   * Applies a Mode to a User (The Client by Default)
   */
  void setMode(String mode, {String user: "PLEASE_INJECT_DEFAULT"}) {
    if (user == "PLEASE_INJECT_DEFAULT") {
      user = nickname;
    }

    send("MODE ${user} ${mode}");
  }

  void knock(String channel, [String message]) {
    if (supported.containsKey("KNOCK") && supported["KNOCK"]) {
      send(message != null ? "KNOCK ${channel}" : "KNOCK ${channel} :${message}");
    } else {
      throw new UnsupportedError("Knocking is not supported on this server.");
    }
  }

  /**
   * Sends [msg] to [target] as a CTCP message
   */
  void sendCTCP(String target, String msg) => sendMessage(target, "\u0001${msg}\u0001");

  /**
   * Sends [msg] to [target] as an action.
   */
  void sendAction(String target, String msg) => sendCTCP(target, "ACTION ${msg}");

  /**
   * Kicks [user] from [channel] with an optional [reason].
   */
  void kick(Channel channel, User user, [String reason]) {
    if (reason != null && supported.containsKey("KICKLEN")) {
      var max = supported["KICKLEN"];
      if (reason.length > max) {
        throw new ArgumentError.value(reason, "length is >${max}, which is the maximum kick comment length set by the server.");
      }
    }
    send("KICK ${channel.name} ${user.nickname}${reason != null ? ' :' + reason : ''}");
  }

  void loginOperator(String name, String password) {
    send("OPER ${name} ${password}");
  }

  void invite(User user, String channel) {
    send("INVITE ${user.nickname} ${channel}");
  }

  Future<ServerVersionEvent> getServerVersion([String target]);
  Future<String> getChannelTopic(String channel);

  Future<bool> isUserOn(String name);

  bool get hasNetworkName => supported.containsKey("NETWORK");
  String get networkName => supported["NETWORK"];
}
