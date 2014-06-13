part of irc;

class Client extends EventEmitting {
  static IRCParser.MessageParser PARSER = new IRCParser.MessageParser();

  Socket _socket;
  bool _ready = false;
  bool _receivedAny;
  BotConfig config;
  List<Channel> channels = [];
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

      switch (event.command) {
        case "376": /* End of MOTD */
          _fire_ready();
          break;
        case "PING": /* Server Ping */
          send("PONG ${event.params[0]}");
          break;
        case "JOIN": /* Join Event */
          String who = event.message.getHostmask()["nick"];
          if (who == _nickname) {
            // We Joined a New Channel
            if (channel(event.params[0]) != null) {
              break;
            }
            channels.add(new Channel(this, event.params[0]));
          }
          fire(Events.Join, new JoinEvent(this, who, channel(event.params[0])));
          break;
        case "PRIVMSG":
          String from = event.message.getHostmask()["nick"];
          String target = event.params[0];
          String message = event.params.last;
          fire(Events.Message, new MessageEvent(this, from, target, message));
          break;
        case "PART":
          String who = event.message.getHostmask()["nick"];

          if (who == _nickname) {
            fire(Events.BotPart, new BotPartEvent(this, channel(event.params[0])));
          } else {
            fire(Events.Part, new PartEvent(this, who, channel(event.params[0])));
          }
          break;
        case "QUIT":
          String who = event.message.getHostmask()["nick"];

          if (who == _nickname) {
            fire(Events.Disconnect, new DisconnectEvent(this));
          } else {
            fire(Events.Quit, new QuitEvent(this, who, channel(event.params[0])));
          }
          break;
        case "332":
          String topic = event.params.last;
          var chan = channel(event.params[1]);
          chan._topic = topic;
          fire(Events.Topic, new TopicEvent(this, chan, topic));
          break;
        case "ERROR":
          String message = event.params.last;
          fire(Events.Error, new ErrorEvent(this, message));
          break;
      }
    });

    on(Events.BotPart).listen((BotPartEvent event) => channels.remove(event.channel));
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
        // Silently Fail
      });

      runZoned(() {
        sock.transform(new Utf8Decoder(allowMalformed: true)).transform(new LineSplitter()).transform(new IRCParser.MessageParser()).listen((message) {
          String command = message.command;
          String prefix = message.prefix;
          List<String> params = message.params;
          fire(Events.LineReceive, new LineReceiveEvent(this, command, prefix, params, message));
        });
      }, onError: (err) {
        // Silently Fail
      });
    });
  }

  void message(String target, String message) {
    send("PRIVMSG ${target} :${message}");
  }

  void notice(String target, String message) {
    send("PRIVMSG ${target} :${message}");
  }

  void send(String line) {
    fire(Events.LineSent, new LineSentEvent(this, PARSER.convert(line)));
    _socket.writeln(line);
  }

  void join(String channel) {
    send("JOIN ${channel}");
  }

  void part(String channel) {
    send("PART ${channel}");
  }

  Channel channel(String name) {
    for (Channel channel in channels) {
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
