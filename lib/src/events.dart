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
  static final EventType<LineReceiveEvent> LineReceive = new EventType<LineReceiveEvent>();
  static final EventType<LineSentEvent> LineSent = new EventType<LineSentEvent>();
  static final EventType<JoinEvent> Join = new EventType<JoinEvent>();
  static final EventType<MessageEvent> Message = new EventType<MessageEvent>();
  static final EventType<PartEvent> Part = new EventType<PartEvent>();
  static final EventType<QuitEvent> Quit = new EventType<QuitEvent>();
  static final EventType<BotJoinEvent> BotJoin = new EventType<BotJoinEvent>();
  static final EventType<BotPartEvent> BotPart = new EventType<BotPartEvent>();
  static final EventType<DisconnectEvent> Disconnect = new EventType<DisconnectEvent>();
  static final EventType<TopicEvent> Topic = new EventType<TopicEvent>();
  static final EventType<ErrorEvent> Error = new EventType<ErrorEvent>();
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

class LineReceiveEvent extends Event {
  String command;
  String prefix;
  List<String> params;
  IRCParser.Message message;

  LineReceiveEvent(Client client, this.command, this.prefix, this.params, this.message) : super(client);
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
}

class BotJoinEvent extends Event {
  Channel channel;

  BotJoinEvent(Client client, this.channel) : super(client);
}

class PartEvent extends Event {
  Channel channel;
  String user;

  PartEvent(Client client, this.user, this.channel) : super(client);

  void reply(String message) {
    channel.message(message);
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

class ErrorEvent extends Event {
  String message;
  dynamic err;
  String type;

  ErrorEvent(Client client, {message: this.message, err: this.err, type: "unspecified"}) : super(client);
}

class LineSentEvent extends Event {
  IRCParser.Message message;

  LineSentEvent(Client client, this.message) : super(client);
}

class TopicEvent extends Event {
  Channel channel;
  String topic;

  TopicEvent(Client client, this.channel, this.topic) : super(client);
}