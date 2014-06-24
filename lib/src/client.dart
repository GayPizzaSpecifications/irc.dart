part of irc;

class Client extends EventDispatcher {
  static final RegExp REGEX = new RegExp(r"^(?:[:](\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$");

  BotConfig config;
  List<Channel> channels = [];

  Map<String, WhoisBuilder> _whois_builders;

  Socket _socket;
  bool _ready = false;
  bool _receivedAny = false;
  String _nickname;
  bool _errored = false;

  final IRCParser parser;

  Client(BotConfig config, [IRCParser parser = null]) : this.parser = parser == null ? new RegexIRCParser() : parser {
    this.config = config;
    _registerHandlers();
    _nickname = config.nickname;
    _whois_builders = new Map<String, WhoisBuilder>();
  }

  void _registerHandlers() {
    register((LineReceiveEvent event) {
      if (!_receivedAny) {
        _receivedAny = true;
        // TODO: review if this sleep is necessary
        sleep(new Duration(milliseconds: 200));
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
          String from = input.hostmask.nickname;
          String target = _parse_nick(input.parameters[0])[0];
          String message = input.message;
          post(new MessageEvent(this, from, target, message));
          break;
        case "PART":
          String who = input.hostmask.nickname;

          var chan_name = input.parameters[0];

          if (who == _nickname) {
            post(new BotPartEvent(this, channel(chan_name)));
          } else {
            post(new PartEvent(this, who, channel(chan_name)));
          }
          break;
        case "QUIT":
          String who = input.hostmask.nickname;

          if (who == _nickname) {
            post(new DisconnectEvent(this));
          } else {
            post(new QuitEvent(this, who, channel(input.parameters[0])));
          }
          break;
        case "332":
          String topic = input.message;
          var chan = channel(input.parameters[1]);
          chan._topic = topic;
          post(new TopicEvent(this, chan, topic));
          break;
        case "ERROR":
          String message = input.message;
          post(new ErrorEvent(this, message: message, type: "server"));
          break;
        case "KICK":
          String who = input.hostmask.nickname;

          if (who == _nickname) { // Temporary Bug Fix
            post(new BotPartEvent(this, channel(input.parameters[0])));
          }
          break;
        case "353":
          List<String> users = input.message.split(" ");
          Channel channel = this.channel(input.parameters[2]);
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
          List<String> split = input.parameters;

          if (split.length < 3) {
            break;
          }

          Channel channel = this.channel(split[0]);
          String mode = split[1];
          String who = split[2];

          post(new ModeEvent(this, mode, who, channel));
          break;

        case "311": /* Begin WHOIS */
          List<String> split = input.parameters;
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
          assert(builder != null);
          builder.server_name = server_name;
          builder.server_info = message;
          break;

        case "313":
          var nickname = input.parameters[0];
          var builder = _whois_builders[nickname];
          assert(builder != null);
          builder.server_operator = true;
          break;

        case "317":
          var split = input.parameters;
          var nickname = split[1];
          var idle = int.parse(split[2]);
          var builder = _whois_builders[nickname];
          assert(builder != null);
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
          assert(builder != null);
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

      register((JoinEvent event) {
        event.channel.members.add(event.user);
      });

      register((PartEvent event) {
        Channel channel = event.channel;
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

  /*
   * [0] = user
   * [1] = realname
   * [2] = hostmask
   */

  List<String> _parse_nick(String nick) {
    return nick.split(new RegExp(r"!~|!|@"));
  }

  void _fire_ready() {
    if (!_ready) {
      _ready = true;
      post(new ReadyEvent(this));
    }
  }

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
      }, onError: (err) {
        post(new ErrorEvent(this, err: err, type: "socket-zone"));
      });
    });
  }

  void message(String target, String input) {
    var all = [];

    var begin = "PRIVMSG ${target} :";

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

    for (String msg in all) {
      send(begin + msg);
    }
  }

  void notice(String target, String message) {
    send("NOTICE ${target} :${message}");
  }

  void send(String line) {
    if (line.length > 510)
      post(new ErrorEvent(this, type: "general", message: "The length of '${line}' is greater than 510 characters"));
    _socket.writeln(line);
    post(new LineSentEvent(this, line));
  }

  void join(String channel) {
    send("JOIN ${channel}");
  }

  void part(String channel) {
    send("PART ${channel}");
  }

  Channel channel(String name) {
    for (var channel in channels) {
      if (channel.name == name) {
        return channel;
      }
    }
    return null;
  }

  void nickname(String nickname) {
    _nickname = nickname;
    send("NICK ${nickname}");
  }

  String getNickname() {
    return _nickname;
  }

  void identify({String username: "PLEASE_INJECT_DEFAULT", String password: "password", String nickserv: "NickServ"}) {
    if (username == "PLEASE_INJECT_DEFAULT") {
      username = config.username;
    }
    message(nickserv, "identify ${username} ${password}");
  }

  void disconnect({String reason: "Client Disconnecting"}) {
    send("QUIT :${reason}");
    sleep(new Duration(milliseconds: 5));
    _socket.close();
  }

  @override
  void post(Event event) {
    if (event is ErrorEvent) {
      _errored = true;
    }
    super.post(event);
  }
}
