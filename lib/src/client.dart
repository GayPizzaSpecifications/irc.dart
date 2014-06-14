part of irc;

class Client extends EventEmitting {

  static RegExp REGEX = new RegExp(r"^(?:[:](\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$");

  BotConfig config;
  List<Channel> channels = [];

  Socket _socket;
  bool _ready = false;
  bool _receivedAny;
  String _nickname;

  Client(BotConfig config) : super(sync: config.synchronous) {
    this.config = config;
    _registerHandlers();
    _nickname = config.nickname;
  }

  void _registerHandlers() {
    on(Events.LineReceive).listen((LineReceiveEvent event) {
      if (!_receivedAny) {
        _receivedAny = true;
        sleep(new Duration(milliseconds: 200));
        send("NICK ${config.nickname}");
        send("USER ${config.username} 8 * :${config.realname}");
      }

      List<String> match = [];
      {
        Match parsed = REGEX.firstMatch(event.line);
        for (int i = 0; i <= parsed.groupCount; i++)
          match.add(parsed.group(i));
      }

      switch (match[2]) { // Command
        case "376": /* End of MOTD */
          _fire_ready();
          break;
        case "PING": /* Server Ping */
          send("PONG ${match[4]}");
          break;
        case "JOIN": /* Join Event */
          String who = _parse_nick(match[1])[0];
          if (who == _nickname) {
             // We Joined a New Channel
            if (channel(match[3]) == null) {
              channels.add(new Channel(this, match[3]));
            }
            fire(Events.BotJoin, new BotJoinEvent(this, channel(match[3])));
          } else {
            fire(Events.Join, new JoinEvent(this, who, channel(match[3])));
          }
          break;
        case "PRIVMSG":
          String from = _parse_nick(match[1])[0];
          String target = _parse_nick(match[3])[0];
          String message = match[4];
          fire(Events.Message, new MessageEvent(this, from, target, message));
          break;
        case "PART":
          String who = _parse_nick(match[1])[0];

          if (who == _nickname) {
            fire(Events.BotPart, new BotPartEvent(this, channel(match[3])));
          } else {
            fire(Events.Part, new PartEvent(this, who, channel(match[3])));
          }
          break;
        case "QUIT":
          String who = _parse_nick(match[1])[0];

          if (who == _nickname) {
            fire(Events.Disconnect, new DisconnectEvent(this));
          } else {
            fire(Events.Quit, new QuitEvent(this, who, channel(match[3])));
          }
          break;
        case "332":
          String topic = match[4];
          var chan = channel(match[3].split(" ")[1]);
          chan._topic = topic;
          fire(Events.Topic, new TopicEvent(this, chan, topic));
          break;
        case "ERROR":
          String message = match[4];
          fire(Events.Error, new ErrorEvent(this, message: message, type: "server"));
          break;
        case "353":
          List<String> users = match[4].split(" ");
          Channel channel = this.channel(match[3].split(" ")[2]);
          users.forEach((user) {
            switch(user[0]) {
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
        case "MODE":          
          List<String> split = match[3].split(" ");
          if (split.length < 3) {
            break;
          }
          
          Channel channel = this.channel(split[0]);
          String mode = split[1];
          String who = split[2];

          fire(Events.Mode, new ModeEvent(this, mode, who, channel));
          break;
        default: /* Command not Handled */
          break;
      }

      on(Events.Quit).listen((QuitEvent event) {
          for (var chan in channels) {
            chan.members.remove(event.user);
            chan.voices.remove(event.user);
            chan.ops.remove(event.user);
          }
      });

      on(Events.Join).listen((JoinEvent event) {
          event.channel.members.add(event.user);
      });

      on(Events.Part).listen((PartEvent event) {
        Channel channel = event.channel;
        channel.members.remove(event.user);
        channel.voices.remove(event.user);
        channel.ops.remove(event.user);
      });

      on(Events.Mode).listen((ModeEvent event) {
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

    on(Events.BotPart).listen((BotPartEvent event) => channels.remove(event.channel));
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
      fire(Events.Ready, new ReadyEvent(this));
    }
  }

  void connect() {
    Socket.connect(config.host, config.port).then((Socket sock) {
      _socket = sock;

      fire(Events.Connect, new ConnectEvent(this));

      sock.handleError((err) {
        fire(Events.Error, new ErrorEvent(this, err: err, type: "socket"));
      });

      runZoned(() {
        sock.transform(new Utf8Decoder(allowMalformed: true)).transform(new LineSplitter()).listen((message) {
          fire(Events.LineReceive, new LineReceiveEvent(this, message));
        });
      }, onError: (err) {
        fire(Events.Error, new ErrorEvent(this, err: err, type: "transform"));
      });
    });
  }

  void message(String target, String message) {
    send("PRIVMSG ${target} :${message}");
  }

  void notice(String target, String message) {
    send("NOTICE ${target} :${message}");
  }

  void send(String line) {
    fire(Events.LineSent, new LineSentEvent(this, line));
    _socket.writeln(line);
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
}
