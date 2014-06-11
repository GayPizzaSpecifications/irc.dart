part of irc;

class EventEmitting {
  EventBus eventBus;

  EventEmitting({sync: false}) {
    eventBus = new EventBus(sync: sync);
  }

  void fire(EventType type, data) {
    eventBus.fire(type, data);
  }

  Stream on(EventType type) {
    return eventBus.on(type);
  }
}

class Events {
  static final EventType<ConnectEvent> Connect = new EventType<ConnectEvent>();
  static final EventType<ReadyEvent> Ready = new EventType<ReadyEvent>();
  static final EventType<LineEvent> Line = new EventType<LineEvent>();
  static final EventType<SendEvent> Send = new EventType<SendEvent>();
  static final EventType<JoinEvent> Join = new EventType<JoinEvent>();
  static final EventType<MessageEvent> Message = new EventType<MessageEvent>();
  static final EventType<PartEvent> Part = new EventType<PartEvent>();
  static final EventType<QuitEvent> Quit = new EventType<QuitEvent>();
  static final EventType<BotPartEvent> BotPart = new EventType<BotPartEvent>();
  static final EventType<DisconnectEvent> Disconnect = new EventType<DisconnectEvent>();
}

abstract class Event {
  Client client;

  Event(Client client) {
    this.client = client;
  }
}

class ConnectEvent extends Event {
  ConnectEvent(Client client) : super(client);
}

class ReadyEvent extends Event {
  ReadyEvent(Client client) : super(client);

  void join(String channel) {
    client.join(channel);
  }
}

class LineEvent extends Event {
  String command;
  String prefix;
  List<String> params;
  IRCParser.Message message;

  LineEvent(Client client, this.command, this.prefix, this.params, this.message) : super(client);
}

class MessageEvent extends Event {
  String from;
  String target;
  String message;

  MessageEvent(Client client, this.from, this.target, this.message) : super(client);

  Channel get channel => client.channel(target);

  void reply(String message) {
    client.message(target, message);
  }
}

class JoinEvent extends Event {
  Channel channel;
  String user;

  JoinEvent(Client client, this.user, this.channel) : super(client);

  void reply(String message) {
    channel.message(message);
  }

  bool isBot() {
    return user == client.config.nickname;
  }
}

class PartEvent extends Event {
  Channel channel;
  String user;

  PartEvent(Client client, this.user, this.channel) : super(client);

  void reply(String message) {
    channel.message(message);
  }

  bool isBot() {
    return user == client.config.nickname;
  }
}

class BotPartEvent extends Event {
  Channel channel;

  BotPartEvent(Client client, this.channel) : super(client);
}

class QuitEvent extends Event {
  Channel channel;
  String user;

  QuitEvent(Client client, this.user, this.channel) : super(client);

  void reply(String message) {
    channel.message(message);
  }
}

class DisconnectEvent extends Event {
  DisconnectEvent(Client client) : super(client);
}

class SendEvent extends Event {
  IRCParser.Message message;

  SendEvent(Client client, this.message) : super(client);
}
