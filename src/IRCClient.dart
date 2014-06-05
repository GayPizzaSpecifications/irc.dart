part of DartBot;

class IRCClient {
    Socket _socket;
    bool _ready = false;
    bool _receivedAny;
    EventBus _eventBus = new EventBus();
    BotConfig config;

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

            sock.transform(UTF8.decoder).transform(new LineSplitter()).transform(new IRCParser.MessageParser()).listen((message) {
                String command = message.command;
                String prefix = message.prefix;
                List<String> params = message.params;
                fire(Events.Line, new LineEvent(this, command, prefix, params, message));
            });
        });
    }

    void send(String line) {
        fire(Events.Send, new SendEvent(this, line));
        _socket.writeln(line);
    }

    void fire(EventType type, data) {
        _eventBus.fire(type, data);
    }

    void join(String channel) {
        send("JOIN ${channel}");
    }

    Stream on(EventType type) {
        return _eventBus.on(type);
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