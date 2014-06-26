part of irc;

/**
 * IRC Client is the most important class in irc.dart
 *
 *      var config = new BotConfig(
 *        nickname: "DartBot",
 *        host: "irc.esper.net",
 *        port: 6667
 *      );
 *      var client = new Client(config);
 *      // Use Client
 */
class Client extends EventDispatcher {
  BotConfig config;

  /**
   * Channels that the Client is in.
   */
  List<Channel> channels = [];

  /**
   * WHOIS Implementation Builder Storage
   */
  Map<String, WhoisBuilder> _whois_builders;

  /**
   * Socket used for Communication between server and client
   */
  Socket _socket;

  /**
   * Flag for if the Client has sent a ReadyEvent
   */
  bool _ready = false;

  /**
   * Flag for if the Client has received any data from the server yet
   */
  bool _receivedAny = false;

  /**
   * Privately Stored Nickname
   */
  String _nickname;

  /**
   * The Client's Nickname
   */
  String get nickname => _nickname;

  /**
   * Flog for if the Client has hit an error
   */
  bool _errored = false;

  /**
   * IRC Parser to use
   */
  final IrcParser parser;

  /**
   * Creates a new IRC Client using the specified configuration
   * If parser is specified, then the parser is used for the current client
   */
  Client(BotConfig config, [IrcParser parser])
      : this.parser = parser == null ? new RegexIrcParser() : parser {
    this.config = config;
    _registerHandlers();
    _nickname = config.nickname;
    _whois_builders = new Map<String, WhoisBuilder>();
  }

  /**
   * Registers all the default handlers.
   * TODO: Implement the irc.protocol library so we can make this cleaner
   */
  void _registerHandlers() {
    register((LineReceiveEvent event) {
      if (!_receivedAny) {
        _receivedAny = true;
        send("NICK ${config.nickname}");
        send("USER ${config.username} 8 * :${config.realname}");
      }

      var input = parser.convert(event.line);

      // Switches on Command
      switch (input.command) {
        case "376": /* End of MOTD */
          _fire_ready();
          break;
        case "PING": /* Server Ping */
          send("PONG :${input.message}");
          break;
        case "JOIN": /* Join Event */
          var who = input.hostmask.nickname;
          var chan_name = input.parameters[0];
          if (who == _nickname) {
            // We Joined a New Channel
            if (channel(chan_name) == null) {
              channels.add(new Channel(this, chan_name));
            }
            post(new BotJoinEvent(this, channel(chan_name)));
          } else {
            post(new JoinEvent(this, who, channel(chan_name)));
          }
          break;
        case "PRIVMSG":
          var from = input.hostmask.nickname;
          var target = _parse_nick(input.parameters[0])[0];
          var message = input.message;
          post(new MessageEvent(this, from, target, message));
          break;
        case "PART":
          var who = input.hostmask.nickname;

          var chan_name = input.parameters[0];

          if (who == _nickname) {
            post(new BotPartEvent(this, channel(chan_name)));
          } else {
            post(new PartEvent(this, who, channel(chan_name)));
          }
          break;
        case "QUIT":
          var who = input.hostmask.nickname;

          if (who == _nickname) {
            post(new DisconnectEvent(this));
          } else {
            post(new QuitEvent(this, who));
          }
          break;
        case "332":
          var topic = input.message;
          var chan = channel(input.parameters[1]);
          chan._topic = topic;
          post(new TopicEvent(this, chan, topic));
          break;
        case "ERROR":
          var message = input.message;
          post(new ErrorEvent(this, message: message, type: "server"));
          break;
        case "KICK":
          var who = input.hostmask.nickname;

          if (who == _nickname) { // Temporary Bug Fix
            post(new BotPartEvent(this, channel(input.parameters[0])));
          }
          break;
        case "353":
          var users = input.message.split(" ");
          var channel = this.channel(input.parameters[2]);
          users.forEach((user) {
            switch (user[0]) {
              case "@":
                channel.ops.add(user.substring(1));
                break;
              case "+":
                channel.voices.add(user.substring(1));
                break;
              default:
                channel.members.add(user);
                break;
            }
          });
          break;

        case "433":
          var original = input.parameters[0];
          post(new NickInUseEvent(this, original));
          break;

        case "NICK":
          var original = input.hostmask.nickname;
          var now = input.message;
          
          post(new NickChangeEvent(this, original, now));
          break;

        case "MODE":
          var split = input.parameters;

          if (split.length < 3) {
            break;
          }

          var channel = this.channel(split[0]);
          var mode = split[1];
          var who = split[2];

          post(new ModeEvent(this, mode, who, channel));
          break;

        case "311": /* Begin WHOIS */
          var split = input.parameters;
          var nickname = split[1];
          var hostname = split[3];
          var realname = input.message;
          var builder = new WhoisBuilder(nickname);
          builder
              ..hostname = hostname
              ..realname = realname;
          _whois_builders[nickname] = builder;
          break;

        case "312":
          var split = input.parameters;
          var nickname = split[1];
          var message = input.message;
          var server_name = split[2];
          var builder = _whois_builders[nickname];
          builder.server_name = server_name;
          builder.server_info = message;
          break;

        case "313":
          var nickname = input.parameters[0];
          var builder = _whois_builders[nickname];
          builder.server_operator = true;
          break;

        case "317":
          var split = input.parameters;
          var nickname = split[1];
          var idle = int.parse(split[2]);
          var builder = _whois_builders[nickname];
          builder.idle = true;
          builder.idle_time  = idle;
          break;

        /* End of WHOIS */
        case "318":
          var nickname = input.parameters[1];
          var builder = _whois_builders.remove(nickname);
          post(new WhoisEvent(this, builder));
          break;

        case "319":
          var nickname = input.parameters[1];
          var message = input.message.trim();
          var builder = _whois_builders[nickname];
          message.split(" ").forEach((chan) {
            if (chan.startsWith("@")) {
              var c = chan.substring(1);
              builder.channels.add(c);
              builder.op_in.add(c);
            } else if (chan.startsWith("+")) {
              var c = chan.substring(1);
              builder.channels.add(c);
              builder.voice_in.add(c);
            } else {
              builder.channels.add(chan);
            }
          });
          break;

        case "330":
          var split = input.parameters;
          var builder = _whois_builders[split[1]];
          builder.username = split[2];
          break;

        case "PONG":
          var message = input.message;
          post(new PongEvent(this, message));
          break;
      }

      register((QuitEvent event) {
        for (var chan in channels) {
          chan.members.remove(event.user);
          chan.voices.remove(event.user);
          chan.ops.remove(event.user);
        }
      });

      register((JoinEvent event) => event.channel.members.add(event.user));

      register((PartEvent event) {
        var channel = event.channel;
        channel.members.remove(event.user);
        channel.voices.remove(event.user);
        channel.ops.remove(event.user);
      });

      register((NickChangeEvent event) {
        if (event.original == _nickname) {
          _nickname = event.now;
        } else {
          for (Channel channel in channels) {
            if (channel.allUsers.contains(event.original)) {
              var old = event.original;
              var now = event.now;
              if (channel.members.contains(old)) {
                channel.members.remove(old);
                channel.members.add(now);
              }
              if (channel.voices.contains(old)) {
                channel.voices.remove(old);
                channel.voices.add(now);
              }
              if (channel.ops.contains(old)) {
                channel.ops.remove(old);
                channel.ops.add(now);
              }
            }
          }
        }
      });

      register((ModeEvent event) {
        if (event.channel != null) {
          var channel = event.channel;
          switch (event.mode) {
            case "+o":
              channel.ops.add(event.user);
              channel.members.remove(event.user);
              break;
            case "+v":
              channel.voices.add(event.user);
              channel.members.remove(event.user);
              break;
            case "-v":
              channel.voices.remove(event.user);
              channel.members.add(event.user);
              break;
            case "-o":
              channel.ops.remove(event.user);
              channel.members.add(event.user);
              break;
          }
        }
      });
    });

    register((BotPartEvent event) => channels.remove(event.channel));
  }

  /**
   * Parses a nickname
   * TODO: Use irc.parser implementation
   */
  List<String> _parse_nick(String nick) => nick.split(new RegExp(r"!~|!|@"));

  /**
   * Fires the Ready Event if it hasn't been fired yet
   */
  void _fire_ready() {
    if (!_ready) {
      _ready = true;
      post(new ReadyEvent(this));
    }
  }

  /**
   * Connects to the IRC Server
   * Any errors are sent through the [ErrorEvent]
   */
  void connect() {
    Socket.connect(config.host, config.port).then((Socket sock) {
      _socket = sock;

      runZoned(() {
        post(new ConnectEvent(this));

        sock.handleError((err) {
          post(new ErrorEvent(this, err: err, type: "socket"));
        }).transform(new Utf8Decoder(allowMalformed: true)).transform(new LineSplitter()).listen((message) {
          post(new LineReceiveEvent(this, message));
        });
      }, onError: (err) => post(new ErrorEvent(this, err: err, type: "socket-zone")));
    });
  }

  /**
   * Sends the [input] to the [target] as a message
   *
   *      client.message("ExampleUser", "Hello World");
   *
   * Note that this handles long messages. If the length of the message is 454
   * characters or bigger, it will split it up into multiple messages
   */
  void message(String target, String message) {
    var begin = "PRIVMSG ${target} :";

    var all = _handle_message_sending(begin, message);

    for (String msg in all) {
      send(begin + msg);
    }
  }

  /**
   * Splits the Messages if required.
   */
  List<String> _handle_message_sending(String begin, String input) {
    var all = [];
    if ((input.length + begin.length) > 454) {
      var max_msg = 454 - (begin.length + 1);
      var sb = new StringBuffer();
      for (int i = 0; i < input.length; i++) {
        sb.write(input[i]);
        if ((i != 0 && (i % max_msg) == 0) || i == input.length - 1) {
          all.add(sb.toString());
          sb.clear();
        }
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
  void notice(String target, String message) {
    var begin = "NOTICE ${target} :";
    var all = _handle_message_sending(begin, message);
    for (String msg in all) {
      send(begin + msg);
    }
  }

  /**
   * Sends [line] to the server
   *
   *      client.send("WHOIS ExampleUser");
   *
   * Will throw an error if [line] is greater than 510 characters
   */
  void send(String line) {
    if (line.length > 510) {
      post(new ErrorEvent(this, type: "general", message: "The length of '${line}' is greater than 510 characters"));
    }
    /* Sending the Line has Priority over then Event */
    _socket.writeln(line);
    post(new LineSentEvent(this, line));
  }

  /**
   * Joins the specified [channel]
   */
  void join(String channel) => send("JOIN ${channel}");

  /**
   * Parts the specified [channel]
   */
  void part(String channel) => send("PART ${channel}");

  /**
   * Gets a Channel object for the channel's [name]
   */
  Channel channel(String name) => channels.firstWhere((channel) => channel.name == name, orElse: () => null);

  /**
   * Changes the Client's Nickname
   *
   * [nickname] is the nickname to change to
   */
  void changeNickname(String nickname) {
    send("NICK ${nickname}");
  }

  /**
   * Identifies the user with the [nickserv].
   *
   * the default [username] is your configured username.
   * the default [password] is password.
   * the default [nickserv] is NickServ.
   */
  void identify({String username: "PLEASE_INJECT_DEFAULT", String password: "password", String nickserv: "NickServ"}) {
    if (username == "PLEASE_INJECT_DEFAULT") {
      username = config.username;
    }
    message(nickserv, "identify ${username} ${password}");
  }

  /**
   * Disconnects the Client with the specified [reason].
   * If [force] is true, then the socket is forcibly closed.
   */
  void disconnect({String reason: "Client Disconnecting", bool force: false}) {
    send("QUIT :${reason}");
    if (force) _socket.close();
  }

  /**
   * Posts a Event to the Event Dispatching System
   * The purpose of this method was to assist in checking for Error Events.
   *
   * [event] is the event to post.
   */
  @override
  void post(Event event) {
    if (event is ErrorEvent) {
      _errored = true;
    }
    super.post(event);
  }
}
