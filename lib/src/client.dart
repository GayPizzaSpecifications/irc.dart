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

    on(Events.Send).listen((SendEvent event) {
      switch (event.message.command) {
        case "QUIT":
          fire(Events.Disconnect, new DisconnectEvent(this));
          break;
      }
    });

    on(Events.Line).listen((LineEvent event) {
      if (!_receivedAny) {
        _receivedAny = true;
        sleep(new Duration(milliseconds: 200));
        send("NICK ${config.nickname}");
        send("USER ${config.username} 8 * :${config.realname}");
      }

      switch (event.command) {
        case "376":
          _fire_ready();
          break;
        case "PING":
          send("PONG ${event.params[0]}");
          _fire_ready();
          break;
        case "JOIN":
          String who = event.message.getHostmask()["nick"];
          if (who == _nickname) {
            // We Joined a New Channel
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
          _socket.destroy();
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
        print(err);
        _socket.destroy();
      });

      sock.transform(new Utf8Decoder(allowMalformed: true)).transform(new LineSplitter()).transform(new IRCParser.MessageParser()).listen((message) {
        String command = message.command;
        String prefix = message.prefix;
        List<String> params = message.params;
        fire(Events.Line, new LineEvent(this, command, prefix, params, message));
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
    fire(Events.Send, new SendEvent(this, PARSER.convert(line)));
    _socket.writeln(line);
  }

  void join(String channel) {
    send("JOIN ${channel}");
  }

  void part(String channel) {
    send("PART ${channel}");
  }

  Channel channel(String name) {
    return channels.firstWhere((channel) {
      return channel.name == name;
    });
  }

  void nickname(String nickname) {
    _nickname = nickname;
    send("NICK ${nickname}");
  }

  void identify({String username: config.username, String password: "password", String nickserv: "NickServ"}) {
    message(nickserv, "identify ${username} ${password}");
  }

  void disconnect({String reason: "Disconnecting"}) {
    send("QUIT :${reason}");
    sleep(new Duration(milliseconds: 5));
    _socket.destroy();
  }

  static void debug(Client client) {
    client.on(Events.Connect).listen((ConnectEvent event) {
      print("[DEBUG] Connected");
    });

    client.on(Events.Ready).listen((ReadyEvent event) {
      print("[DEBUG] Ready");
    });

    client.on(Events.Line).listen((LineEvent event) {
      print("[DEBUG] Received Line: ${event.message}");
    });

    client.on(Events.Send).listen((SendEvent event) {
      print("[DEBUG] Sent Line: ${event.message}");
    });
  }
}
