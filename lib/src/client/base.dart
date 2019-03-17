part of irc.client;

/// Base Class for a Client
abstract class ClientBase {
  /// Parser for client
  IrcParser get parser;

  /// Client configuration
  Configuration get config;

  /// Client nickname
  String get nickname;

  /// Map of channel name and channel instance for which
  /// the client is currently in.
  Map<String, Channel> get channels;

  /// Map of user nickname and user instance for every channel
  /// that this client is in.
  Map<String, User> get users;

  /// MOTD of the server, which is available only after the
  /// ReadyEvent is posted.
  String get motd;

  /// Flag stating whether the client is connected.
  bool get connected;

  /// Map of information regarding what the server supports.
  Map<String, dynamic> get supported;

  /// Sends the [message] to the [target] as a message.
  ///
  /// client.message("ExampleUser", "Hello World");
  ///
  /// Note that this handles long messages. If the length of the message is 454
  /// characters or bigger, it will split it up into multiple messages
  void sendMessage(String target, String message) {
    var begin = "PRIVMSG ${target} :";

    var all = _handleMessageSending(begin, message);

    for (String msg in all) {
      send(begin + msg);
    }
  }

  /// Change the client's nickname.
  /// [nickname] the nickname to change to
  void changeNickname(String nickname) {
    if (supported.containsKey("MAXNICKLEN") ||
        supported.containsKey("NICKLEN")) {
      var max = supported.containsKey("MAXNICKLEN")
          ? supported["MAXNICKLEN"]
          : supported["NICKLEN"];

      if (nickname.length > max) {
        throw new ArgumentError("Nickname is too big for the server.");
      }
    }

    send("NICK ${nickname}");
  }

  /// Splits messages if required.
  /// [begin] is the very beginning of the line (like 'PRIVMSG user :')
  /// [input] is the message
  List<String> _handleMessageSending(String begin, String input) {
    if (config.enableMessageSplitting && input.contains("\n")) {
      var combined = new List<String>();
      for (String part in input.split("\n")) {
        combined.addAll(_handleMessageSending(begin, part));
      }
      return combined;
    }

    var all = <String>[];

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

  /// Sends the [input] to the [target] as a notice
  ///
  /// client.notice("ExampleUser", "Hello World");
  ///
  /// Note that this handles long messages. If the length of the message is 454
  /// characters or bigger, it will split it up into multiple messages
  void sendNotice(String target, String message) {
    var begin = "NOTICE ${target} :";
    var all = _handleMessageSending(begin, message);
    for (String msg in all) {
      send(begin + msg);
    }
  }

  /// Sends a line prefixed by [prefix], with a section of [parts] joined by [joinBy].
  /// When the line would be too long, it will generate a new line.
  void sendAutoSplit(String prefix, List<String> parts,
      [String joinBy = " ", bool now = false]) {
    var line = "${prefix}";
    var empty = true;
    while (parts.isNotEmpty) {
      var current = line;
      var candidate = parts.removeAt(0);
      if (empty) {
        current += candidate;
        empty = false;
      } else {
        current += "${joinBy}${candidate}";
      }

      if (current.length > 510) {
        send(line, now: now);
        line = "${prefix}${candidate}";
      } else {
        line = current;
      }
    }

    if (!empty) {
      send(line, now: now);
    }
  }

  /// Identifies the user with the [nickserv].
  ///
  /// the default [username] is your configured username.
  /// the default [password] is password.
  /// the default [nickserv] is NickServ.
  void identify(
      {String username = "____DART_PLEASE_INJECT_DEFAULT____",
      String password = "password",
      String nickserv = "NickServ",
      String generateMessage(String user, String password) = _nickserv}) {
    if (username == "____DART_PLEASE_INJECT_DEFAULT____") {
      username = config.username;
    }

    sendMessage(nickserv, generateMessage(username, password));
  }

  static String _nickserv(String username, String password) =>
      "identify ${username} ${password}";

  /// Sends [line] to the server
  ///
  ///  client.send("WHOIS ExampleUser");
  ///
  /// Will throw an error if [line] is greater than 510 characters
  void send(String line, {bool now = false});

  /// Gets a channel object for the channel's [name].
  /// Returns null if no such channel exists.
  Channel getChannel(String name);

  /// Get a user object for the server.
  /// Returns null if no such user exists.
  User getUser(String nickname);

  /// Joins the specified [channel].
  void join(String channel) {
    if (supported.containsKey("CHANNELLEN")) {
      var max = supported["CHANNELLEN"];
      if (channel.length > max) {
        throw new ArgumentError.value(channel,
            "length is >${max}, which is the maximum channel name length set by the server.");
      }
    }
    send("JOIN ${channel}");
  }

  /// Parts the specified [channel].
  void part(String channel) {
    if (supported.containsKey("CHANNELLEN")) {
      var max = supported["CHANNELLEN"];
      if (channel.length > max) {
        throw new ArgumentError.value(channel,
            "length is >${max}, which is the maximum channel name length set by the server.");
      }
    }
    send("PART ${channel}");
  }

  /// Disconnects the Client with the specified [reason].
  /// If [force] is true, then the socket is forcibly closed.
  /// When it is forcibly closed, a future is returned.
  Future disconnect({String reason = "Client Disconnecting"});

  /// Connects to the IRC Server
  /// Any errors are sent through the [ErrorEvent].
  void connect();

  /// Posts a Event to the Event Dispatching System
  /// The purpose of this method was to assist in checking for Error Events.
  ///
  /// [event] is the event to post.
  void post(Event event);

  /// Applies a Mode to a User (The Client by Default)
  void setMode(String mode,
      {String user = "____DART_PLEASE_INJECT_DEFAULT____"}) {
    if (user == "____DART_PLEASE_INJECT_DEFAULT____") {
      user = nickname;
    }

    send("MODE ${user} ${mode}");
  }

  void knock(String channel, [String message]) {
    if (supported.containsKey("KNOCK") && supported["KNOCK"]) {
      send(message != null
          ? "KNOCK ${channel}"
          : "KNOCK ${channel} :${message}");
    } else {
      throw new UnsupportedError("Knocking is not supported on this server.");
    }
  }

  /// Sends [msg] to [target] as a CTCP message
  void sendCTCP(String target, String msg) =>
      sendMessage(target, "\u0001${msg}\u0001");

  /// Sends [msg] to [target] as an action.
  void sendAction(String target, String msg) =>
      sendCTCP(target, "ACTION ${msg}");

  /// Kicks [user] from [channel] with an optional [reason].
  void kick(Channel channel, User user, [String reason]) {
    if (reason != null && supported.containsKey("KICKLEN")) {
      var max = supported["KICKLEN"];
      if (reason.length > max) {
        throw new ArgumentError.value(reason,
            "length is > ${max}, which is the maximum kick comment length set by the server.");
      }
    }
    send(
        "KICK ${channel.name} ${user.nickname}${reason != null ? ' :' + reason : ''}");
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
