part of irc.client;

/**
 * Base Class for IRC Events
 */
abstract class Event {
  /**
   * Client associated with the Event
   */
  Client client;

  Event(this.client);
}

/**
 * Connect Event is dispatched when the client connects to the server
 */
class ConnectEvent extends Event {
  ConnectEvent(Client client)
      : super(client);
}

/**
 * Ready Event is dispatched when the client is ready to join channels
 */
class ReadyEvent extends Event {
  ReadyEvent(Client client)
      : super(client);

  /**
   * Joins the specified [channel].
   */
  void join(String channel) {
    client.join(channel);
  }
}

/**
 * Line Receive Event is dispatched when a line is received from the server
 */
class LineReceiveEvent extends Event {
  /**
   * Line from the Server
   */
  String line;

  LineReceiveEvent(Client client, this.line)
      : super(client);
}

/**
 * Message Event is dispatched when a message is received from the server (includes private messages)
 */
class MessageEvent extends Event {
  /**
   * Who sent the message
   */
  String from;

  /**
   * Where the message was sent to
   */
  String target;

  /**
   * The message that was received
   */
  String message;

  MessageEvent(Client client, this.from, this.target, this.message)
      : super(client);

  /**
   * Gets the Channel of this Event (returns null if target is a user)
   */
  Channel get channel => client.getChannel(target);

  /**
   * Replies to the Event
   */
  void reply(String message) {
    if (isPrivate) {
      client.sendMessage(from, message);
    } else {
      client.sendMessage(target, message);
    }
  }

  /**
   * If this event is a private message
   */
  bool get isPrivate => target == client.nickname;
}

/**
 * Notice Event is dispatched when a notice is received
 */
class NoticeEvent extends MessageEvent {

  /**
   * Returns whether the notice is from the system or not.
   */
  bool get isSystem => target == "*";

  NoticeEvent(Client client, String from, String target, String message)
      : super(client, from, target, message);

  /**
   * Sends [message] to [target] as a notice.
   */
  @override
  void reply(String message) => client.sendNotice(from, message);
}

/**
 * Join Event is dispatched when another user joins a channel we are in
 */
class JoinEvent extends Event {
  /**
   * Channel they joined
   */
  Channel channel;

  /**
   * User who joined
   */
  String user;

  JoinEvent(Client client, this.user, this.channel)
      : super(client);

  /**
   * Replies to this Event by sending [message] to the channel
   */
  void reply(String message) => channel.sendMessage(message);
}

/**
 * Nick In Use Event is dispatched when a nickname is in use when trying to switch usernames
 */
class NickInUseEvent extends Event {
  /**
   * Original Nickname
   */
  String original;

  NickInUseEvent(Client client, this.original)
      : super(client);
}

/**
 * Bot Join Event is dispatched when the Client joins a Channel
 */
class BotJoinEvent extends Event {
  /**
   * Channel we joined
   */
  Channel channel;

  BotJoinEvent(Client client, this.channel)
      : super(client);
}

/**
 * Part Event is dispatched when a user parts a channel that the Client is in
 */
class PartEvent extends Event {
  /**
   * Channel that the user left
   */
  Channel channel;

  /**
   * The user that left
   */
  String user;

  PartEvent(Client client, this.user, this.channel)
      : super(client);

  /**
   * Replies to the Event by sending [message] to the channel the user left
   */
  void reply(String message) => channel.sendMessage(message);
}

/**
 * Bot Part Event is dispatched when the Client parts a channel
 */
class BotPartEvent extends Event {
  /**
   * Channel we left
   */
  Channel channel;

  BotPartEvent(Client client, this.channel)
      : super(client);
}

/**
 * Quit Event is dispatched when a user quits the server
 */
class QuitEvent extends Event {
  /**
   * User who quit
   */
  String user;

  QuitEvent(Client client, this.user)
      : super(client);
}

/**
 * Disconnect Event is dispatched when we disconnect from the server
 */
class DisconnectEvent extends Event {
  DisconnectEvent(Client client)
      : super(client);
}

/**
 * Error Event is dispatched when there is any error in the Client or Server
 */
class ErrorEvent extends Event {
  /**
   * Error Message
   */
  String message;

  /**
   * Error Object (possibly null)
   */
  Error err;

  /**
   * Type of Error
   */
  String type;

  ErrorEvent(Client client, {this.message, this.err, this.type: "unspecified"})
      : super(client);
}

/**
 * Mode Event is dispatched when we are notified of a mode change
 */
class ModeEvent extends Event {
  /**
   * Channel we received the change from (possibly null)
   */
  Channel channel;

  /**
   * Mode that was changed
   */
  String mode;

  /**
   * User the mode was changed on
   */
  String user;

  ModeEvent(Client client, this.mode, this.user, [this.channel])
      : super(client);
}

/**
 * Line Sent Event is dispatched when the Client sends a line to the server
 */
class LineSentEvent extends Event {
  /**
   * Line that was sent
   */
  String line;

  LineSentEvent(Client client, this.line)
      : super(client);
}

/**
 * Topic Event is dispatched when the topic changes or is received in a channel
 */
class TopicEvent extends Event {
  /**
   * Channel we received the event from
   */
  Channel channel;

  /**
   * The Topic
   */
  String topic;

  TopicEvent(Client client, this.channel, this.topic)
      : super(client);
}

/**
 * Nick Change Event is dispatched when a nickname changes (possibly the Client's nickname)
 */
class NickChangeEvent extends Event {
  /**
   * Original Nickname
   */
  String original;

  /**
   * New Nickname
   */
  String now;

  NickChangeEvent(Client client, this.original, this.now)
      : super(client);
}

/**
 * Whois Event is dispatched when a WHOIS query is completed
 */
class WhoisEvent extends Event {
  WhoisBuilder builder;

  WhoisEvent(Client client, this.builder)
      : super(client);

  /**
   * The Channels the user is a member in
   */
  List<String> get member_in {
    var list = <String>[];
    list.addAll(builder.channels.where((i) => !operatorChannels.contains(i) && !voicedChannels.contains(i)));
    return list;
  }

  /**
   * The Channels the user is an operator in
   */
  List<String> get operatorChannels => builder.opIn;

  /**
   * The Channels the user is a voice in
   */
  List<String> get voicedChannels => builder.voiceIn;

  /**
   * If the user is away
   */
  bool get away => builder.away;

  /**
   * If the user is away, then this is the message that was set
   */
  String get awayMessage => builder.awayMessage;

  /**
   * If this user is a server operator
   */
  bool get isServerOperator => builder.isServerOperator;

  /**
   * The name of the server this user is on
   */
  String get serverName => builder.serverName;

  /**
   * The Server Information (message) for the server this user is on
   */
  String get serverInfo => builder.serverInfo;

  /**
   * The User's Username
   */
  String get username => builder.username;

  /**
   * The User's Hostname
   */
  String get hostname => builder.hostname;

  /**
   * If the user is idle
   */
  bool get idle => builder.idle;

  /**
   * If the user is idle, then this is the amount of time that the user has been idle
   */
  int get idleTime => builder.idleTime;

  /**
   * The User's Real Name
   */
  String get realname => builder.realname;

  /**
   * The User's Nickname
   */
  String get nickname => builder.nickname;

  @override
  String toString() => builder.toString();
}

class PongEvent extends Event {
  /**
   * Message in the PONG
   */
  String message;

  PongEvent(Client client, this.message)
      : super(client);
}

/**
 * An Action Event
 */
class ActionEvent extends MessageEvent {
  ActionEvent(Client client, String from, String target, String message)
      : super(client, from, target, message);

  /**
   * Sends [message] to [target] as a action.
   */
  @override
  void reply(String message) => client.sendAction(from, message);
}

/**
 * A Kick Event
 */
class KickEvent extends Event {
  /**
   * The Channel where the event is from
   */
  Channel channel;

  /**
   * The User who was kicked
   */
  String user;

  /**
   * The User who kicked the other user
   */
  String by;

  /**
   * The Reason Given for [by] kicking [user]
   */
  String reason;

  KickEvent(Client client, this.channel, this.user, this.by, [this.reason]) : super(client);
}

/**
 * A Client to Client Protocol Event.
 * ActionEvent is executed on this event as well.
 */
class CTCPEvent extends Event {
  /**
   * The User who sent the message
   */
  String user;

  /**
   * The Target of the message
   */
  String target;

  /**
   * The Message sent
   */
  String message;

  CTCPEvent(Client client, this.user, this.target, this.message) : super(client);
}

/**
 * Server MOTD Recieved
 */
class MOTDEvent extends Event {
  /**
   * MOTD Message
   */
  String message;

  MOTDEvent(Client client, this.message) : super(client);
}

/**
 * Server ISUPPORT Event
 */
class ServerSupportsEvent extends Event {
  /**
   * Supported Stuff
   */
  Map<String, dynamic> supported;

  ServerSupportsEvent(Client client, String message) : super(client) {
    supported = {};
    var split = message.split(" ");
    split.forEach((it) {
      if (it.contains("=")) {
        var keyValue = it.split("=");
        var key = keyValue[0];
        var value = keyValue[1];
        try {
          value = num.parse(value);
        } catch (e) {
        }
        supported[key] = value;
      } else {
        supported[it] = true;
      }
    });
  }
}

/**
 * Invite Event
 */
class InviteEvent extends Event {
  /**
   * The Channel that the client was invited to
   */
  String channel;
  
  /**
   * The user who invited the client
   */
  String user;
  
  InviteEvent(Client client, this.channel, this.user) : super(client);
  
  /**
   * Joins the Channel
   */
  void join() => client.join(channel);
  
  /**
   * Sends a Message to the User
   */
  void reply(String message) => client.sendMessage(user, message);
}
