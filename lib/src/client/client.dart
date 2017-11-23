part of irc.client;

/**
 * IRC Client is the primary class in irc.dart.
 *
 *      var config = new Configuration(
 *        nickname: "DartBot",
 *        host: "irc.esper.net",
 *        port: 6667
 *      );
 *      var client = new Client(config);
 *      // Use Client
 */
class Client extends ClientBase {

  /**
   * Event Dispatcher.
   */
  final EventDispatcher dispatcher = new EventDispatcher();

  /**
   * Configuration for the Client.
   */
  @override
  Configuration config;

  /**
   * List of Channels.
   */
  @override
  List<Channel> channels = [];

  /**
   * List of Users.
   */
  @override
  List<User> users = [];

  /**
   * WHOIS Implementation Builder Storage.
   */
  Map<String, WhoisBuilder> _whoisBuilders;

  /**
   * Connection System.
   */
  IrcConnection connection;

  /**
   * Flag for if the Client has sent a ReadyEvent.
   */
  bool _ready = false;

  /**
   * Privately Stored Nickname.
   */
  String _nickname;

  /**
   * Instance of the class that parses incoming messages.
   */
  @override
  final IrcParser parser;

  /**
   * Send interval for buffer.
   */
  final Duration sendInterval;

  /**
   * Boolean whether the Client is connected to the server or not.
   */
  @override
  bool connected = false;

  /**
   * Storage for any data.
   * This will persist when you connect and disconnect.
   */
  final Map<String, dynamic> metadata;

  /**
   * Stores the MOTD
   */
  String _motd = "";

  /**
   * Server Supports
   */
  Map<String, dynamic> _supported = {};

  /**
   * Server Supports
   */
  Map<String, dynamic> get supported => _supported;

  /**
   * Creates a new IRC Client using the specified configuration
   * If parser is specified, then the parser is used for the current client
   */
  Client(Configuration config, {
    IrcParser parser,
    IrcConnection connection,
    this.sendInterval: const Duration(milliseconds: 2)
  })
      : this.parser = parser == null ? new RegexIrcParser() : parser,
        this.connection = connection == null
            ? new SocketIrcConnection()
            : connection,
        this.metadata = {} {
    this.config = config;
    _registerHandlers();
    _nickname = config.nickname;
    _whoisBuilders = <String, WhoisBuilder>{};
    monitor = new Monitor(this);
  }

  /**
   * Get the Server's MOTD.
   */
  @override
  String get motd => _motd;

  /**
   * Get the Client's nickname.
   */
  @override
  String get nickname => _nickname;

  /**
   * Get a User.
   */
  @override
  Channel getChannel(String name) => channels.firstWhere(
      (channel) => channel.name == name, orElse: () => null);

  bool isChannelName(String input) {
    var prefixes = supported["CHANTYPES"].toString();
    if (prefixes == null) {
      prefixes = "#";
    }

    return prefixes.split("").any((x) {
      return input.startsWith(x);
    });
  }

  /**
   * Get a User.
   */
  @override
  User getUser(String nickname) => users.firstWhere(
      (user) => user.nickname == nickname, orElse: () => null);

  /**
   * Get an Entity for the Server.
   */
  Entity getEntity(String entityName) {
    if (getChannel(entityName) != null) {
      return getChannel(entityName);
    } else if (getUser(entityName) != null) {
      return getUser(entityName);
    } else {
      return new Server(entityName);
    }
  }

  /**
   * Connect the User to the Server.
   */
  @override
  void connect() {
    _ready = false;
    connection.connect(config).then((_) {
      _timer = new Timer.periodic(sendInterval, (t) {
        flush(all: false);
      });

      connection.lines().listen((line) {
        post(new LineReceiveEvent(this, line));
      });

      post(new ConnectEvent(this));
    });
  }

  List<String> _queue = [];

  /**
   * Disconnect the Client from the Server.
   */
  @override
  Future disconnect({String reason: "Client Disconnecting"}) {
    send("QUIT :${reason}");
    post(new DisconnectEvent(this));
    flush();
    return connection.disconnect();
  }

  /**
   * Flushes the line queue.
   * If [all] is true, then all lines are sent,
   * otherwise only one line is sent.
   */
  void flush({bool all: true}) {
    if (_queue.isEmpty) {
      return;
    }

    do {
      var line = _queue.removeAt(0);

      /* Sending the line has priority over the event */
      connection.send(line);
      post(new LineSentEvent(this, line));
    } while (all && _queue.isNotEmpty);
  }

  /**
   * Fires an event to registered listeners. Any listeners that take the
   * specific type [event] will be called.
   */
  void post(Event event) {
    dispatcher.post(event);
    _controller.add(event);

    if (_batchId != null) {
      event.isBatched = true;
      event.batchId = _batchId;
      _batchedEvents.add(event);
    }
  }

  /**
   * Registers a method so that it can start receiving events.
   *
   * A filter can be provided to determine when the [handler] will
   * be called. If the [filter] returns true then the [handler] will
   * not be called, otherwise it will be called. If no [filter] is
   * provided then the [handler] will always be called upon posting an
   * event.
   *
   * A [priority] can be provided which will specify in what order the handler will be called in.
   * The higher a priority is, the quicker it will be called in the handler list when an event is posted.
   *
   * Returns false if [method] is already registered, otherwise true.
   */
  bool register(EventHandlerFunction handler, {EventFilter filter, int priority}) {
    return filter == null ?
      dispatcher.register(handler, priority: priority) :
      dispatcher.register(handler, filter: filter, priority: priority);
  }

  /**
   * Gets the next event of the specified [type].
   */
  Future<dynamic> pollEvent(Type type) {
    return events.where((it) => it.runtimeType == type).first;
  }

  /**
   * Unregisters a [handler] from receiving events. If the specific [handler]
   * has a filter, it should be provided in order to properly unregister the
   * listener. If the specific [handler] has a priority, it should be provided as well.
   * Returns whether the [handler] was removed or not.
   */
  bool unregister(EventHandlerFunction handler, {EventFilter filter, int priority}) {
    return filter == null ?
      dispatcher.unregister(handler, priority: priority) :
      dispatcher.unregister(handler, filter: filter, priority: priority);
  }

    List<Event> _batchedEvents = [];

  /**
   * Send a raw line on the socket.
   */
  @override
  void send(String line, {bool now: false}) {
    /* Max Line Length for IRC is 512. With the newlines (\r\n or \n) we can only send 510 character lines */
    if (line.length > 510) {
      throw new ArgumentError(
          "The length of '${line}' is greater than 510 characters");
    }

    if (now) {
      /* Sending the line has priority over the event */
      connection.send(line);
      post(new LineSentEvent(this, line));
    } else {
      _queue.add(line);
    }
  }

  /**
   * Fires the Ready Event if it hasn't been fired yet.
   */
  void _fireReady() {
    if (!_ready) {
      _ready = true;
      post(new ReadyEvent(this));
    }
  }

  Map<String, String> _topicQueue = {};

  /**
   * Registers all the default handlers.
   */
  void _registerHandlers() {
    register((ConnectEvent event) {
      if (config.enableCapabilityNegotiation) {
        var list = config.capabilities.toSet();
        var caps = {
          "invite-notify": config.enableInviteNotify,
          "account-tag": config.enableAccountTag,
          "extended-join": config.enableExtendedJoin,
          "multi-prefix": config.enableMultiPrefix,
          "self-message": config.enableSelfMessage,
          "away-notify": config.enableAwayNotify,
          "account-notify": config.enableAccountNotify,
          "server-time": config.enableServerTime,
          "userhost-in-names": config.enableUserHostInNames,
          "chghost": config.enableChangeHost,
          "batch": config.enableBatch
        };

        for (var cap in caps.keys) {
          if (caps[cap] == true) {
            list.add(cap);
          }
        }

        if (list.isNotEmpty) {
          listSupportedCapabilities().then((supported) {
            var m = supported
              .capabilities
              .map((it) => it.startsWith("~") ? it.substring(1) : it)
              .toList();
            var needsAck = supported
              .capabilities
              .where((it) => it.startsWith("~")).map((it) => it.substring(1))
              .toList();

            for (var c in new Set<String>.from(list)) {
              if (!m.contains(c)) {
                list.remove(c);
              }
            }

            requestCapability(list.join(" "), now: true);

            events
            .where((it) => it is AcknowledgedCapabilitiesEvent ||
              it is NotAcknowledgedCapabilitiesEvent)
            .first
            .timeout(const Duration(seconds: 10)).then((event) {
              if (event is AcknowledgedCapabilitiesEvent) {
                if (event.capabilities.any((it) => needsAck.contains(it))) {
                  send("CAP ACK :${event.capabilities.join(" ")}");
                }
              }
              send("CAP END");
            }).catchError((e) {
              send("CAP END");
            });
          });
        }
      }

      if (config.password != null) {
        send("PASS ${config.password}", now: true);
      }

      send("NICK ${config.nickname}", now: true);
      send("USER ${config.username} ${config.username} ${config.host} :${config.realname}", now: true);
    });

    register((LineSentEvent event) {
      var input = event.message;

      if (input == null) {
        return;
      }

      switch (input.command) {
        case "PRIVMSG":
          if (input.parameters.isEmpty) {
            return;
          }
          var msg = input.message;
          var target = input.parameters[0];
          post(new MessageSentEvent(this, msg, target));
          break;
      }
    });

    register((LineReceiveEvent event) {
      // Parse the IRC Input
      var input = event.message;

      if (input == null) {
        return;
      }

      if (input.isBatched) {
        _batchId = input.batchId;
        var list = _batches[_batchId];

        if (list != null) {
          list.add(input);
        }
      }

      switch (input.command) {
        case "376": // End of MOTD
          post(new MOTDEvent(this, _motd));
          _fireReady();
          break;

        case "422": // No MOTD Found
          post(new MOTDEvent(this, 'No MOTD file present on the server.'));
          _fireReady();
          break;

        case "PING": // Server Ping
          send("PONG :${input.message}");
          break;

        case "JOIN": // User Joined Channel
          var who = input.hostmask.nickname;
          var chanName = input.parameters.length != 0
              ? input.parameters[0]
              : input.message;
          if (who == _nickname) {
            // We joined a new channel
            if (getChannel(chanName) == null) {
              channels.add(new Channel(this, chanName));
            }
            post(new ClientJoinEvent(this, getChannel(chanName)));
            getChannel(chanName).reloadBans();
          } else {
            // User joined one of our channels
            var event = new JoinEvent(this, who, getChannel(chanName));
            if (_currentCap.contains("extended-join")) {
              event.username = input.parameters[1];
              event.realname = input.message;
            }
            post(event);
          }
          break;

        case "PRIVMSG": // Message
          _fireReady();
          var from = getUser(input.hostmask.nickname);
          var target = input.parameters[0];
          var message = input.message;

          if (from == nickname && _currentCap.contains("self-message")) {
            post(new MessageSentEvent(this, message, target));
          } else {
            if (message.startsWith("\u0001")) {
              // CTCP
              post(new CTCPEvent(this, from, getEntity(target), message.substring(1, message.length - 1)));
            } else if (input.tags.containsKey("intent") && input.tags["intent"] == "ACTION") {
              // Action
              post(new ActionEvent(this, from, getEntity(target), message));
            } else {
              // Message
              post(new MessageEvent(this, from, getEntity(target), message, intent: input.tags["intent"]));
            }
          }
          break;

        case "ACCOUNT": // IRCv3.1 account-notify extension
          var user = input.hostmask.nickname;
          var username = input.parameters[0];

          if (username == "*") {
            post(new UserLoggedOutEvent(this, getUser(user)));
          } else {
            post(new UserLoggedInEvent(this, getUser(user), username));
          }
          break;

        case "NOTICE": // Notice
          var from = getEntity(input.plainHostmask);
          if (input.parameters[0] != "*") from = getUser(input.hostmask.nickname);

          var target = getEntity(input.parameters[0]);
          var message = input.message;
          post(new NoticeEvent(this, from, target, message));
          break;

        case "PART": // User left Channel
          var who = input.hostmask.nickname;

          var chan_name = input.parameters.length != 0
              ? input.parameters[0]
              : input.message;

          if (who == _nickname) {
            post(new ClientPartEvent(this, getChannel(chan_name)));
          } else {
            post(new PartEvent(this, who, getChannel(chan_name)));
          }
          break;

        case "QUIT": // User quit
          var who = input.hostmask.nickname;

          if (who == _nickname) {
            // We quit
            post(new DisconnectEvent(this));
            flush();
            connection.disconnect();
          } else {
            // Somebody quit
            post(new QuitEvent(this, who));
          }
          break;

        case "332": // Topic
          var topic = input.message;
          var chan = input.parameters[1];

          _topicQueue[chan] = topic;
          break;

        case "333": // Topic User
          var channel = getChannel(input.parameters[1]);
          var user = new Hostmask.parse(input.parameters[2]).nickname;
          var topic = _topicQueue.remove(channel.name);
          var old = channel._topic;
          channel._topic = topic;
          channel._topicUser = user;
          post(new TopicEvent(this, channel, getUser(user), topic, old));
          break;

        case "AWAY": // User marked as away
          var user = input.hostmask.nickname;
          var msg = input.message;
          post(new AwayEvent(this, getUser(user), msg));
          break;

        case "TOPIC": // Topic changed
          var topic = input.message;
          var user = input.hostmask.nickname;
          var chan = getChannel(input.parameters[0]);
          var old = chan._topic;
          chan._topic = topic;
          chan._topicUser = user;
          post(new TopicEvent(this, chan, getUser(user), topic, old, true));
          break;

        case "ERROR": // Server error
          var message = input.message;
          post(new ErrorEvent(this, message: message, type: "server"));
          break;

        case "353": // Channel user list
          var users = input.message.split(" ")
            ..removeWhere((it) => it.trim().isEmpty);
          if (_currentCap.contains("userhost-in-names")) {
            users = users.map((it) {
              return new Hostmask.parse(it).nickname;
            }).toList();
          }

          var channel = this.getChannel(input.parameters[2]);

          users.forEach((user) {
            var chars = new List<String>.generate(user.length, (i) => user[i]);
            var cs = chars.takeWhile((it) => modePrefixes.containsValue(it));

            var name = chars.skip(cs.length).join();

            if (getUser(name) == null) {
              this.users.add(new User(this, name));
            }

            var userInstance = getUser(name);
            if (cs.length == 0) {
              channel.members.add(userInstance);
            }
            for (var n in cs) {
              switch (n) {
                case "@":
                  channel.ops.add(userInstance);
                  break;
                case "+":
                  channel.voices.add(userInstance);
                  break;
                case "%":
                  channel.halfops.add(userInstance);
                  break;
                case "~":
                  channel.owners.add(userInstance);
                  break;
              }
            }
          });
          break;

        case "CHGHOST": // User changed hostname
          var user = input.hostmask.nickname;
          var username = input.parameters[0];
          var host = input.parameters[1];

          post(new ChangeHostEvent(this, user, username, host));
          break;

        case "433": // Nickname is in use
          var original = input.parameters[0];
          post(new NickInUseEvent(this, original));
          break;

        case "NICK": // Nickname changed
          var original = input.hostmask.nickname;
          var now = input.message;

          // Posts the nickname change event. No need for checking if we are the original nickname.
          post(new NickChangeEvent(this, getUser(original), original, now));
          break;

        case "MODE": // Mode Changed
          var split = input.parameters;

          if (split.isEmpty) {
            break;
          }

          if (isChannelName(split[0])) {
            var channel = getChannel(split[0]);
            var mode = IrcParserSupport.parseMode(split[1]);
            var who = split.length == 3 ? split[2] : null;

            if (mode.modes.contains("b")) {
              channel.reloadBans();
            }

            if (who == null) {
              if (mode.isAdded) {
                channel.mode.modes.addAll(mode.added);
              } else {
                channel.mode.modes.removeWhere(mode.removed.contains);
              }
            }

            post(new ModeEvent(this, mode, who, channel));
          } else {
            var who = split[0];
            var mode = IrcParserSupport.parseMode(input.message);
            post(new ModeEvent(this, mode, who));
          }
          break;

        case "311": // Beginning of WHOIS
          var split = input.parameters;
          var nickname = split[1];
          var hostname = split[3];
          var realname = input.message;
          var builder = new WhoisBuilder(nickname);
          builder.hostname = hostname;
          builder.realname = realname;
          builder._createTimestamp = new DateTime.now();
          _whoisBuilders[nickname] = builder;
          break;

        case "312": // WHOIS Server information
          var split = input.parameters;
          var nickname = split[1];
          var message = input.message;
          var server_name = split[2];
          var builder = _whoisBuilders[nickname];
          builder.serverName = server_name;
          builder.serverInfo = message;
          break;

        case "301": // WHOIS Away Information
          var split = input.parameters;
          var nickname = split[1];
          var message = input.message;
          var builder = _whoisBuilders[nickname];
          builder.away = true;
          builder.awayMessage = message;
          break;

        case "313": // WHOIS Operator information
          var nickname = input.parameters[0];
          var builder = _whoisBuilders[nickname];
          if (builder != null) {
            builder.isServerOperator = true;
          }
          break;

        case "BATCH": // Allows collapsing of messages from the server
          var isEnd = input.parameters[0].startsWith("-");
          var id = input.parameters[0].substring(1);
          if (isEnd) {
            var messages = [];
            var events = [];

            if (_batches.containsKey(id)) {
              var captured = _batches[id];
              messages = captured.where((it) => it is Message).toList();
              events = captured.where((it) => it is Event).toList();

              _batches.remove(id);
            }

            var event = new BatchEndEvent(this, id, messages, events);
            post(event);
          } else {
            _batches[id] = [];
            var bodyP = new List<String>.from(input.parameters).skip(1).toList();
            var bodyStr = bodyP.join(" ");
            if (input.message != null) {
              bodyStr += " :${input.message}";
            }
            var body = parser.convert(bodyStr);
            post(new BatchStartEvent(this, id, body));
          }
          break;

        case "317": // WHOIS idle information
          var split = input.parameters;
          var nickname = split[1];
          var idle = int.parse(split[2]);
          var builder = _whoisBuilders[nickname];
          builder.idle = true;
          builder.idleTime = idle;
          break;

        case "318": // End of WHOIS
          var nickname = input.parameters[1];
          var builder = _whoisBuilders.remove(nickname);
          post(new WhoisEvent(this, builder));
          break;

        case "319": // WHOIS Channel information
          var nickname = input.parameters[1];

          if (input.message == null) {
            break;
          }

          var message = input.message.trim();

          var builder = _whoisBuilders[nickname];
          message.split(" ").forEach((chan) {
            if (chan.startsWith("@")) {
              var c = chan.substring(1);
              builder.channels.add(c);
              builder.opIn.add(c);
            } else if (chan.startsWith("+")) {
              var c = chan.substring(1);
              builder.channels.add(c);
              builder.voiceIn.add(c);
            } else if (chan.startsWith("~")) {
              var c = chan.substring(1);
              builder.channels.add(c);
              builder.ownerIn.add(c);
            } else if (chan.startsWith("%")) {
              var c = chan.substring(1);
              builder.channels.add(c);
              builder.halfOpIn.add(c);
            } else {
              if (chan.startsWith("!")) {
                chan = chan.substring(1);
              }
              builder.channels.add(chan);
            }
          });
          break;

        case "330": // WHOIS account information
          var split = input.parameters;
          var builder = _whoisBuilders[split[1]];
          builder.username = split[2];
          break;

        case "PONG": // PONG from Server
          var message = input.message;
          post(new PongEvent(this, message));
          break;

        case "367": // Ban list entry
          var channel = getChannel(input.parameters[1]);
          if (channel == null) {
            // We Were Banned
            break;
          }
          var ban = input.parameters[2];
          channel.bans.add(new GlobHostmask(ban));
          break;

        case "KICK": // User kicked from channel
          var channel = getChannel(input.parameters[0]);
          var user = input.parameters[1];
          var reason = input.message;
          var by = input.hostmask.nickname;
          post(new KickEvent(this, channel, getUser(user), getUser(by), reason));
          break;

        case "372": // MOTD part
          var p = input.message;
          if (_motd.isEmpty) {
            _motd += p;
          } else {
            _motd += "\n" + p;
          }
          break;

        case "005": // ISUPPORT
          var params = input.parameters;
          params.removeAt(0);
          var message = params.join(" ");
          post(new ServerSupportsEvent(this, message));
          break;
        case "CAP": // Capability
          _handleCAP(input);
          break;

        case "INVITE": // We were invited to a channel
          var inviter = input.hostmask.nickname;
          var user = input.parameters[0];
          var channel = input.parameters[1];
          if (user == nickname) {
            post(new InviteEvent(this, channel, inviter));
          } else {
            post(new UserInvitedEvent(this, getChannel(channel), user, getUser(inviter)));
          }
          break;

        case "730": // User online notification for IRCv3.2 monitor extension
          var users = input.message.trim().split(" ");
          users.removeWhere((it) => it == " ");
          for (var user in users) {
            post(new UserOnlineEvent(this, user));
          }
          break;

        case "731": // User offline notification for IRCv3.2 monitor extension
          var users = input.message.trim().split(" ");
          users.removeWhere((it) => it == " ");
          for (var user in users) {
            post(new UserOfflineEvent(this, user));
          }
          break;

        case "732": // Monitor list for IRCv3.2 monitor extension
          var users = input.message.trim().split(" ");
          users.removeWhere((it) => it == " ");
          _monitorList.addAll(users);
          break;

        case "733": // End of monitor list for IRCv3.2 monitor extension
          var users = new List<String>.from(_monitorList);
          _monitorList.clear();
          post(new MonitorListEvent(this, users));
          break;

        case "303": // ISON Response
          List<String> users;
          if (input.message == null) {
            users = [];
          } else {
            users = input.message.split(" ").map((it) => it.trim()).toList();
          }

          post(new IsOnEvent(this, users));
          break;

        case "351": // Server version response
          var version = input.parameters[1];
          var server = input.parameters[2];
          var comments = input.message;

          post(new ServerVersionEvent(this, server, version, comments));

          break;
        case "381": // Client is now an server operator
          post(new ServerOperatorEvent(this));
          break;
      }

      if (input.isBatched) {
        _batchId = null;
        _batches[input.batchId].addAll(_batchedEvents);
        _batchedEvents.clear();
      }
    });

    // Set the connection status
    register((ConnectEvent event) => this.connected = true);

    register((DisconnectEvent event) {
      this.connected = false;

      if (_timer != null && _timer.isActive) {
        _timer.cancel();
      }
    });

    // Handles user quit
    register((QuitEvent event) {
      for (var chan in channels) {
        if (chan.allUsers.contains(event.user)) {
          post(new QuitPartEvent(this, chan, event.user));
          chan.members.remove(event.user);
          chan.voices.remove(event.user);
          chan.ops.remove(event.user);
          chan.halfops.remove(event.user);
          chan.owners.remove(event.user);
        }
      }
    });

    register((BatchStartEvent event) {
      if (event.type == "NETSPLIT") { // Servers lost connection and netsplit
        event.waitForEnd().then((e) {
          var hub = event.body.parameters[0];
          var host = event.body.parameters[1];
          var quits = e.events.where((it) => it is QuitEvent).toList();
          post(new NetSplitEvent(this, hub, host, quits));
        });
      } else if (event.type == "NETJOIN") { // Netsplit servers converged
        event.waitForEnd().then((e) {
          var hub = event.body.parameters[0];
          var host = event.body.parameters[1];
          var joins = e.events.where((it) => it is JoinEvent).toList();
          post(new NetJoinEvent(this, hub, host, joins));
        });
      }
    });

    // Handles CTCP Events so the action event can be executed
    register((CTCPEvent event) {
      if (event.message.startsWith("ACTION ")) {
        post(new ActionEvent(this, event.user, event.target, event.message.substring(7)));
      }
    });

    /* Handles User Tracking in Channels when a user joins. A user is a member until it is changed. */
    register((JoinEvent event) {
      if (getUser(event.user) == null) {
        this.users.add(new User(this, event.user));
      }
      event.channel.members.add(getUser(event.user));
    });

    // Handles User Tracking in Channels when a user leaves
    register((PartEvent event) {
      var channel = event.channel;
      var user = getUser(event.user);
      channel.members.remove(user);
      channel.voices.remove(user);
      channel.ops.remove(user);
      channel.owners.remove(user);
      channel.halfops.remove(user);
    });

    // Handles User Tracking in Channels when a user is kicked.
    register((KickEvent event) {
      var channel = event.channel;
      var user = event.user;
      channel.members.remove(user);
      channel.voices.remove(user);
      channel.ops.remove(user);
      channel.owners.remove(user);
      channel.halfops.remove(user);
      if (event.user == nickname) {
        channels.remove(channel);
      }
    });

    // Handles Nickname Changes
    register((NickChangeEvent event) {
      getUser(event.original)._nickname = event.now;
      if (event.original == _nickname) {
        _nickname = event.now;
      }
    });

    // Handles Channel User Tracking
    register((ModeEvent event) {
      if (event.channel != null) {
        var channel = event.channel;
        var prefixes = _modePrefixes;

        var added = event.mode.isAdded;

        for (var mode in event.mode.modes) {
          if (!prefixes.containsKey(mode)) {
            return;
          }

          var prefix = prefixes[mode];
          var owner = mode == "q" && prefix == "@";
          var op = prefix == "@";
          var voice = prefix == "+";
          var halfop = prefix == "%";

          void m(Set<User> users) {
            if (added) {
              users.add(getUser(event.user));
            } else {
              users.remove(getUser(event.user));
            }
          }

          if (owner) {
            m(channel.owners);
          }

          if (op) {
            m(channel.ops);
          }

          if (voice) {
            m(channel.voices);
          }

          if (halfop) {
            m(channel.halfops);
          }
        }
      }
    });

    // When the Client leaves a channel, we no longer retain the object.
    register((ClientPartEvent event) => channels.remove(event.channel));

    register((ServerSupportsEvent event) {
      _supported.addAll(event.supported);
      _modePrefixes = IrcParserSupport.parseSupportedPrefixes(_supported["PREFIX"]);
    });

    register((WhoisEvent event) {
      User user = getUser(event.nickname);
      if (user == null) {
        user = new User(this, event.nickname);
        users.add(user);
      }
      user._realname = event.realname;
      user._hostname = event.hostname;
      user._serverName = event.serverName;
      user._serverInfo = event.serverInfo;
      user._isServerOperator = event.isServerOperator;
    });
  }

  /**
   * Get the current capabilities
   */
  Future<CurrentCapabilitiesEvent> listCurrentCapabilities() {
    var f = onEvent(CurrentCapabilitiesEvent).first;
    send("CAP LS");
    return f;
  }

  /**
   * Get all supported capabilities
   */
  Future<ServerCapabilitiesEvent> listSupportedCapabilities() {
    var f = onEvent(ServerCapabilitiesEvent).first;
    send("CAP LIST");
    return f;
  }

  /**
   * Handle capability commands
   */
  void _handleCAP(Message input) {
    var cmd = input.parameters[1];

    switch (cmd) {
      case "LS": // All capabilities
        _supportedCap = input.message != null ? input.message.trim().split(" ").toSet() : new Set<String>();
        _supportedCap.removeWhere((it) => it == " " || it.trim().isEmpty);
        post(new ServerCapabilitiesEvent(this, _supportedCap));
        break;
      case "LIST": // Current capabilities
        _currentCap = input.message != null ? input.message.trim().split(" ").toSet() : new Set<String>();
        _currentCap.removeWhere((it) => it == " " || it.trim().isEmpty);
        post(new CurrentCapabilitiesEvent(this, _currentCap));
        break;
      case "ACK": // Acknowledged capabilities
        var caps = input.message != null ? input.message.trim().split(" ").toSet() : new Set<String>();
        caps.removeWhere((it) => it == " " || it.trim().isEmpty);
        _currentCap.addAll(caps);
        post(new AcknowledgedCapabilitiesEvent(this, caps));
        break;
      case "NAK": // Not acknowledged capabilities
        var caps = input.message != null ? input.message.trim().split(" ").toSet() : new Set<String>();
        caps.removeWhere((it) => it == " " || it.trim().isEmpty);
        _currentCap.removeWhere((it) => caps.contains(it));
        post(new NotAcknowledgedCapabilitiesEvent(this, caps));
        break;
    }
  }

  Map<String, String> _modePrefixes = {};
  Set<String> _supportedCap = new Set<String>();
  Set<String> _currentCap = new Set<String>();

  Map<String, String> get modePrefixes => _modePrefixes;

  /**
   * Get the state of a user
   */
  @override
  Future<bool> isUserOn(String name, {Duration timeout: const Duration(seconds: 5)}) {
    var completer = new Completer.sync();

    var handler = (WhoisEvent event) {
      if (event.nickname == nickname) {
        if (!completer.isCompleted) {
          completer.complete(event.away);
        }
      }
    };

    register(handler);
    send("ISON ${name}");

    return completer.future.timeout(timeout, onTimeout: () => false).then((value) {
      new Future(() {
        unregister(handler);
      });
      return value;
    });
  }

  /**
   * Get the Server version
   */
  @override
  Future<ServerVersionEvent> getServerVersion([String target]) {
    var completer = new Completer();

    pollEvent(ServerVersionEvent).then((event) {
      completer.complete(event);
    });

    send(target != null ? "VERSION ${target}" : "VERSION");

    return completer.future.timeout(const Duration(seconds: 3),
        onTimeout: () => throw new UnsupportedError(
            "Server Version Information may not be supported on this server."));
  }

  /**
   * Get a Channel's topic.
   */
  @override
  Future<String> getChannelTopic(String channel) {
    var completer = new Completer();

    onEvent(TopicEvent).where((it) => it.channel.name == channel).first.then((e) {
      completer.complete(e.topic);
    });

    send("TOPIC ${channel}");

    return completer.future;
  }

  /**
   * Set a Channel's topic.
   */
  void setChannelTopic(String channel, String topic) {
    if (supported.containsKey("TOPICLEN")) {
      var length = supported["TOPICLEN"];

      if (topic.length > length) {
        throw new ArgumentError("Topic exceeds maximum length.");
      }
    }

    send("TOPIC ${channel} :${topic}");
  }

  /**
   * Refresh the User list for a Channel.
   */
  void refreshUserList(String channel) {
    send("NAMES ${channel}");
  }

  /**
   * Request a capability.
   */
  void requestCapability(String name, {bool now: false}) {
    send("CAP REQ :${name}", now: now);
  }

  /**
   * Check if the Server has a capability.
   */
  bool hasCapability(String name) {
    return currentCapabilities.contains(name);
  }

  /**
   * Check if the Server has support for a capability.
   */
  bool hasSupportForCapability(String name) {
    return serverCapabilities.contains(name);
  }

  Set<String> get serverCapabilities => _supportedCap;
  Set<String> get currentCapabilities => _currentCap;

  /**
   * Run callback on type event.
   */
  Stream<Event> onEvent(Type type) {
    return events.where((it) => it.runtimeType == type);
  }

  Monitor monitor;

  Stream<ConnectEvent> get onConnect => onEvent(ConnectEvent);
  Stream<DisconnectEvent> get onDisconnect => onEvent(DisconnectEvent);
  Stream<MessageEvent> get onMessage => onEvent(MessageEvent);
  Stream<ClientJoinEvent> get onClientJoin => onEvent(ClientJoinEvent);
  Stream<ClientPartEvent> get onClientPart => onEvent(ClientPartEvent);
  Stream<JoinEvent> get onJoin => onEvent(JoinEvent);
  Stream<PartEvent> get onPart => onEvent(PartEvent);
  Stream<QuitEvent> get onQuit => onEvent(QuitEvent);
  Stream<QuitPartEvent> get onQuitPart => onEvent(QuitPartEvent);
  Stream<NoticeEvent> get onNotice => onEvent(NoticeEvent);
  Stream<ActionEvent> get onAction => onEvent(ActionEvent);
  Stream<PongEvent> get onPong => onEvent(PongEvent);
  Stream<TopicEvent> get onTopic => onEvent(TopicEvent);
  Stream<ModeEvent> get onMode => onEvent(ModeEvent);
  Stream<WhoisEvent> get onWhois => onEvent(WhoisEvent);
  Stream<ReadyEvent> get onReady => onEvent(ReadyEvent);
  Stream<LineReceiveEvent> get onLineReceive => onEvent(LineReceiveEvent);
  Stream<LineSentEvent> get onLineSent => onEvent(LineSentEvent);
  Stream<InviteEvent> get onInvite => onEvent(InviteEvent);
  Stream<IsOnEvent> get onIsOn => onEvent(IsOnEvent);

  Stream<Event> get events => _controller.stream;

  StreamController _controller = new StreamController.broadcast();

  String _batchId;

  /**
   * Send a message to all users. Requires operator status.
   */
  void wallops(String message) {
    send("WALLOPS :${message}");
  }

  Map<String, List<dynamic>> _batches = {};

  Timer _timer;

  List<String> _monitorList = [];

  /**
   * Run a WHOIS query against a user.
   */
  Future<WhoisEvent> whois(String user,
      {Duration timeout: const Duration(seconds: 5)}) {
    var completer = new Completer();
    onEvent(WhoisEvent).where((it) => it.nickname == user).first.then((e) {
      completer.complete(e);
    });
    send("WHOIS ${user}");
    return completer.future.timeout(
      timeout, onTimeout: () => throw new UserNotFoundException(user)
    );
  }
}

/**
 * Monitor a user's status.
 */
class Monitor {
  final Client client;

  Monitor(this.client) {
    client.register((UserOnlineEvent event) {
      statuses[event.user] = true;
    });

    client.register((UserOfflineEvent event) {
      statuses[event.user] = false;
    });
  }

  /**
   * Current user statuses.
   */
  Map<String, bool> _statuses = {};

  Map<String, bool> get statuses => _statuses;

  bool get isSupported => client._supported.containsKey("MONITOR");

  /**
   * Add a monitor for a user.
   */
  void add(String user) {
    _checkMonitorSupported();
    client.send("MONITOR + ${user}");
    _monitorList.add(user);
  }

  /**
   * Add a monitor for multiple users.
   */
  void addAll(Iterable<String> users) {
    _checkMonitorSupported();
    client.send("MONITOR + ${users.join(" ")}");
    _monitorList.addAll(users);
  }

  /**
   * Remove a monitor for a user.
   */
  void remove(String user) {
    _checkMonitorSupported();
    client.send("MONITOR - ${user}");
    _monitorList.remove(user);
    _statuses.remove(user);
  }

  /**
   * Remove a monitor for multiple users.
   */
  void removeAll(Iterable<String> users) {
    _checkMonitorSupported();
    client.send("MONITOR - ${users.join(" ")}");
    _monitorList.removeWhere(users.contains);
    users.forEach(_statuses.remove);
  }

  /**
   * Clear all monitors.
   */
  void clear() {
    _checkMonitorSupported();
    client.send("MONITOR C");
    _monitorList.clear();
    _statuses.clear();
  }

  /**
   * Check if a user is monitored.
   */
  bool isUserMonitored(String user) {
    return users.contains(user);
  }

  /**
   * Check if a user is online.
   */
  bool isUserOnline(String user) {
    return statuses[user];
  }

  /**
   * Check if a user is offline.
   */
  bool isUserOffline(String user) {
    return statuses[user] == false;
  }

  /**
   * Limit for user monitors.
   */
  int get limit {
    if (client._supported["MONITOR"] == true) {
      return 9999999999;
    } else {
      return client._supported["MONITOR"];
    }
  }

  Set<String> _monitorList = new Set<String>();

  Set<String> get users => _monitorList;

  /**
   * Checks whether the monitor extension is supported.
   */
  void _checkMonitorSupported() {
    if (!client._supported.containsKey("MONITOR")) {
      throw new UnsupportedError("Monitor is not supported on this server.");
    }
  }
}

/**
 * An exception for when an IRC User is not found.
 */
class UserNotFoundException {
  final String user;

  UserNotFoundException(this.user);

  @override
  String toString() => "${user} was not found.";
}
