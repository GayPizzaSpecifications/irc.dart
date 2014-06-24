part of irc;

abstract class Event {
  Client client;

  Event(this.client);
}

class ConnectEvent extends Event {
  ConnectEvent(Client client)
      : super(client);
}

class ReadyEvent extends Event {
  ReadyEvent(Client client)
      : super(client);

  void join(String channel) {
    client.join(channel);
  }
}

class LineReceiveEvent extends Event {
  String line;

  LineReceiveEvent(Client client, this.line)
      : super(client);
}

class MessageEvent extends Event {
  String from;
  String target;
  String message;

  MessageEvent(Client client, this.from, this.target, this.message)
      : super(client);

  Channel get channel => client.channel(target);

  void reply(String message) {
    if (isPrivate) {
      client.message(from, message);
    } else {
      client.message(target, message);
    }
  }

  bool get isPrivate => target == client.nickname;
}

class JoinEvent extends Event {
  Channel channel;
  String user;

  JoinEvent(Client client, this.user, this.channel)
      : super(client);

  void reply(String message) => channel.message(message);
}

class NickInUseEvent extends Event {
  String original;

  NickInUseEvent(Client client, this.original)
      : super(client);
}

class BotJoinEvent extends Event {
  Channel channel;

  BotJoinEvent(Client client, this.channel)
      : super(client);
}

class PartEvent extends Event {
  Channel channel;
  String user;

  PartEvent(Client client, this.user, this.channel)
      : super(client);

  void reply(String message) => channel.message(message);
}

class BotPartEvent extends Event {
  Channel channel;

  BotPartEvent(Client client, this.channel)
      : super(client);
}

class QuitEvent extends Event {
  Channel channel;
  String user;

  QuitEvent(Client client, this.user, this.channel)
      : super(client);

  void reply(String message) => channel.message(message);
}

class DisconnectEvent extends Event {
  DisconnectEvent(Client client)
      : super(client);
}

class ErrorEvent extends Event {
  String message;
  Error err;
  String type;

  ErrorEvent(Client client, {this.message, this.err, this.type: "unspecified"})
      : super(client);
}

class ModeEvent extends Event {
  Channel channel;
  String mode;
  String user;

  ModeEvent(Client client, this.mode, this.user, [this.channel])
      : super(client);
}

class LineSentEvent extends Event {
  String line;

  LineSentEvent(Client client, this.line)
      : super(client);
}

class TopicEvent extends Event {
  Channel channel;
  String topic;

  TopicEvent(Client client, this.channel, this.topic)
      : super(client);
}

class NickChangeEvent extends Event {
  String original;
  String now;

  NickChangeEvent(Client client, this.original, this.now)
      : super(client);
}

class WhoisEvent extends Event {
  WhoisBuilder builder;

  WhoisEvent(Client client, this.builder)
      : super(client);

  List<String> get member_in {
    var list = <String>[];
    list.addAll(builder.channels.where((i) => !op_in.contains(i) && !voice_in.contains(i)));
    return list;
  }

  List<String> get op_in => builder.op_in;
  List<String> get voice_in => builder.voice_in;
  bool get away => builder.away;
  String get away_message => builder.away_message;
  bool get server_operator => builder.server_operator;
  String get server_name => builder.server_name;
  String get server_info => builder.server_info;
  String get username => builder.username;
  String get hostname => builder.hostname;
  bool get idle => builder.idle;
  int get idle_time => builder.idle_time;
  String get realname => builder.realname;
  String get nickname => builder.nickname;

  String toString() => builder.toString();
}

class PongEvent extends Event {
  String message;

  PongEvent(Client client, this.message)
      : super(client);
}