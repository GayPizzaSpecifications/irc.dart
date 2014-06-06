part of irc;

class EventEmitting {
    EventBus _eventBus = new EventBus();

    void fire(EventType type, data) {
        _eventBus.fire(type, data);
    }

    Stream on(EventType type) {
        return _eventBus.on(type);
    }
}

class IRCClient extends EventEmitting {
    Socket _socket;
    bool _ready = false;
    bool _receivedAny;
    EventBus _eventBus = new EventBus();
    BotConfig config;
    List<Channel> channels = [];

    IRCClient(this.config) {
        _registerHandlers();
    }

    void _registerHandlers() {
        on(Events.Line).listen((LineEvent event) {
            if (!_receivedAny) {
                _receivedAny = true;
                sleep(new Duration(milliseconds: 200));
                send("NICK ${config.nickname}");
                send("USER ${config.username} 8 * :${config.realname}");
            }

            if (event.command == "PING") {
                send("PONG ${event.params[0]}");

                if (!_ready) {
                    _ready = true;
                    fire(Events.Ready, new ReadyEvent(this));
                }
            }

            switch (event.command) {
                case "PING":
                    send("PONG ${event.params[0]}");

                    if (!_ready) {
                        _ready = true;
                        fire(Events.Ready, new ReadyEvent(this));
                    }
                    break;
                case "JOIN":
                    String who = event.message.getHostmask()["nick"];
                    if (who == config.nickname) {
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
            }
        });
    }

    void connect() {
        Socket.connect(config.host, config.port).then((Socket sock) {
            _socket = sock;

            fire(Events.Connect, new ConnectEvent(this));

            sock.handleError((err) {
                print(err);
                sock.close();
            });

            sock.transform(UTF8.decoder).transform(new LineSplitter()).transform(new _irc_message.MessageParser()).listen((message) {
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
        fire(Events.Send, new SendEvent(this, line));
        _socket.writeln(line);
    }

    void join(String channel) {
        send("JOIN ${channel}");
    }

    Channel channel(String name) {
        return channels.firstWhere((channel) {
            return channel.name == name;
        });
    }

    void disconnect({String reason: "Disconnecting"}) {
        send("QUIT :${reason}");
        sleep(new Duration(milliseconds: 5));
        _socket.close();
    }

    static void debug(IRCClient client) {
        client.on(Events.Connect).listen((ConnectEvent event) {
            print("[DEBUG] Connected");
        });

        client.on(Events.Ready).listen((ReadyEvent event) {
            print("[DEBUG] Ready");
        });

        client.on(Events.Line).listen((LineEvent event) {
            print("[DEBUG] Recieved Line: ${event.message}");
        });

        client.on(Events.Send).listen((SendEvent event) {
            print("[DEBUG] Sent Line: ${event.line}");
        });
    }
}