part of irc.client;

/// Base Class for IRC Events
abstract class Event {
  /// Client associated with the Event
  Client client;

  bool isBatched = false;
  String batchId;

  Event(this.client);
}

/// Connect Event is dispatched when the client connects to the server
class ConnectEvent extends Event {
  ConnectEvent(Client client) : super(client);
}

class BatchStartEvent extends Event {
  String id;
  String get type => body.parameters[1];
  Message body;

  BatchStartEvent(Client client, this.id, this.body) : super(client);

  Future<BatchEndEvent> waitForEnd() {
    return client.onEvent<BatchEndEvent>().where((it) => it.id == id).first;
  }
}

class BatchEndEvent extends Event {
  String id;
  List<Message> messages;
  List<Event> events;

  BatchEndEvent(Client client, this.id, this.messages, this.events)
      : super(client);
}

class MessageSentEvent extends Event {
  String message;
  String target;

  MessageSentEvent(Client client, this.message, this.target) : super(client);
}

class NetSplitEvent extends Event {
  String hub;
  String host;
  List<QuitEvent> quits;

  NetSplitEvent(Client client, this.hub, this.host, this.quits) : super(client);
}

class NetJoinEvent extends Event {
  String hub;
  String host;
  List<JoinEvent> joins;

  NetJoinEvent(Client client, this.hub, this.host, this.joins) : super(client);
}

class QuitPartEvent extends Event {
  final Channel channel;
  final String user;

  QuitPartEvent(Client client, this.channel, this.user) : super(client);
}

/// Ready Event is dispatched when the client is ready to join channels
class ReadyEvent extends Event {
  ReadyEvent(Client client) : super(client);

  /// Joins the specified [channel].
  void join(String channel) {
    client.join(channel);
  }
}

class IsOnEvent extends Event {
  final List<String> users;

  IsOnEvent(Client client, this.users) : super(client);
}

class ServerOperatorEvent extends Event {
  ServerOperatorEvent(Client client) : super(client);
}

class ServerTlsEvent extends Event {
  ServerTlsEvent(Client client) : super(client);
}

class ServerVersionEvent extends Event {
  final String version;
  final String server;
  final String comments;

  ServerVersionEvent(Client client, this.server, this.version, this.comments)
      : super(client);
}

/// Line Receive Event is dispatched when a line is received from the server
class LineReceiveEvent extends Event {
  /// Line from the Server
  String line;

  Message _message;

  Message get message {
    if (_message != null) {
      return _message;
    } else {
      return _message = client.parser.convert(line);
    }
  }

  LineReceiveEvent(Client client, this.line) : super(client);
}

class UserOnlineEvent extends Event {
  String user;

  UserOnlineEvent(Client client, this.user) : super(client);
}

class UserOfflineEvent extends Event {
  String user;

  UserOfflineEvent(Client client, this.user) : super(client);
}

class MonitorListEvent extends Event {
  List<String> users;

  MonitorListEvent(Client client, this.users) : super(client);
}

class ChangeHostEvent extends Event {
  String host;
  String user;
  String username;

  ChangeHostEvent(Client client, this.user, this.username, this.host)
      : super(client);
}

/// Message Event is dispatched when a message is received from the server (includes private messages)
class MessageEvent extends Event {
  /// Who sent the message
  Entity from;

  /// Where the message was sent to
  Entity target;

  /// The message that was received
  String message;

  /// Message Intent
  String intent;

  MessageEvent(Client client, this.from, this.target, this.message,
      {this.intent})
      : super(client);

  /// Replies to the Event
  void reply(String message) {
    if (target.isUser) {
      client.sendMessage(from.name, message);
    } else if (target.isChannel) {
      client.sendMessage(target.name, message);
    } else {
      // Ignore server replies.
    }
  }

  /// If this event is a private message
  bool get isPrivate => target.isUser;

  Channel get channel => target.isChannel ? target as Channel : null;
}

/// Notice Event is dispatched when a notice is received
class NoticeEvent extends MessageEvent {
  /// Returns whether the notice is from the system or not.
  bool get isSystem => from != null && from.isServer;

  bool get isServer => isSystem;

  NoticeEvent(Client client, Entity from, Entity target, String message)
      : super(client, from, target, message);

  bool get isChannel => target.isChannel;

  /// Sends [message] to [target] as a notice.
  @override
  void reply(String message) {
    if (!from.isServer) {
      client.sendNotice(from.name, message);
    }
  }
}

/// Join Event is dispatched when another user joins a channel we are in
class JoinEvent extends Event {
  /// Channel they joined
  Channel channel;

  /// User who joined
  String user;

  String username;
  String realname;

  bool get isExtended => realname != null;
  bool get isRegistered => username != "*";

  JoinEvent(Client client, this.user, this.channel,
      {this.username, this.realname})
      : super(client);

  /// Replies to this Event by sending [message] to the channel
  void reply(String message) => channel.sendMessage(message);
}

/// Nick In Use Event is dispatched when a nickname is in use when trying to switch usernames
class NickInUseEvent extends Event {
  /// Original Nickname
  String original;

  NickInUseEvent(Client client, this.original) : super(client);
}

/// Fired when the Client joins a Channel.
class ClientJoinEvent extends Event {
  /// Channel we joined
  Channel channel;

  ClientJoinEvent(Client client, this.channel) : super(client);
}

/// Part Event is dispatched when a user parts a channel that the Client is in
class PartEvent extends Event {
  /// Channel that the user left
  Channel channel;

  /// The user that left
  String user;

  PartEvent(Client client, this.user, this.channel) : super(client);

  /// Replies to the Event by sending [message] to the channel the user left
  void reply(String message) => channel.sendMessage(message);
}

/// Fired when the Client parts a channel
class ClientPartEvent extends Event {
  /// Channel we left
  Channel channel;

  ClientPartEvent(Client client, this.channel) : super(client);
}

/// Quit Event is dispatched when a user quits the server
class QuitEvent extends Event {
  /// User who quit
  String user;

  QuitEvent(Client client, this.user) : super(client);
}

/// Disconnect Event is dispatched when we disconnect from the server
class DisconnectEvent extends Event {
  DisconnectEvent(Client client) : super(client);
}

/// Error Event is dispatched when there is any error in the Client or Server
class ErrorEvent extends Event {
  /// Error Message
  String message;

  /// Error Object (possibly null)
  Error err;

  /// Type of Error
  String type;

  ErrorEvent(Client client, {this.message, this.err, this.type = "unspecified"})
      : super(client);
}

/// Mode Event is dispatched when we are notified of a mode change
class ModeEvent extends Event {
  /// Channel we received the change from (possibly null)
  Channel channel;

  /// Mode that was changed
  ModeChange mode;

  /// User the mode was changed on
  String user;

  bool get isClient => user == client.nickname;
  bool get hasChannel => channel != null;
  bool get isChannel => hasChannel && user == null;

  ModeEvent(Client client, this.mode, this.user, [this.channel])
      : super(client);
}

/// Line Sent Event is dispatched when the Client sends a line to the server
class LineSentEvent extends Event {
  /// Line that was sent
  String line;

  Message _message;

  Message get message {
    if (_message != null) {
      return _message;
    } else {
      return _message = client.parser.convert(line);
    }
  }

  LineSentEvent(Client client, this.line) : super(client);
}

/// Topic Event is dispatched when the topic changes or is received in a channel
class TopicEvent extends Event {
  /// Channel we received the event from
  Channel channel;

  /// The Topic
  String topic;

  /// The old Topic.
  String oldTopic;

  /// The User
  User user;

  bool isChange;

  TopicEvent(Client client, this.channel, this.user, this.topic, this.oldTopic,
      [this.isChange = false])
      : super(client);

  void revert() {
    channel.topic = oldTopic;
  }
}

class ServerCapabilitiesEvent extends Event {
  Set<String> capabilities;

  ServerCapabilitiesEvent(Client client, this.capabilities) : super(client);
}

class AcknowledgedCapabilitiesEvent extends Event {
  Set<String> capabilities;

  AcknowledgedCapabilitiesEvent(Client client, this.capabilities)
      : super(client);
}

class NotAcknowledgedCapabilitiesEvent extends Event {
  Set<String> capabilities;

  NotAcknowledgedCapabilitiesEvent(Client client, this.capabilities)
      : super(client);
}

class AwayEvent extends Event {
  User user;
  String message;
  bool get isAway => message != null;
  bool get isBack => message == null;

  AwayEvent(Client client, this.user, this.message) : super(client);
}

class CurrentCapabilitiesEvent extends Event {
  Set<String> capabilities;

  CurrentCapabilitiesEvent(Client client, this.capabilities) : super(client);
}

class WhowasEvent extends Event {
  final String nickname;
  final String user;
  final String host;
  final String realname;

  WhowasEvent(Client client, this.nickname, this.user, this.host, this.realname)
      : super(client);
}

/// Nick Change Event is dispatched when a nickname changes (possibly the Client's nickname)
class NickChangeEvent extends Event {
  /// User object
  User user;

  /// Original Nickname
  String original;

  /// New Nickname
  String now;

  NickChangeEvent(Client client, this.user, this.original, this.now)
      : super(client);
}

class UserLoggedInEvent extends Event {
  /// User that logged in.
  User user;

  /// Account name for the user.
  String account;

  UserLoggedInEvent(Client client, this.user, this.account) : super(client);
}

class UserLoggedOutEvent extends Event {
  User user;

  UserLoggedOutEvent(Client client, this.user) : super(client);
}

/// Whois Event is dispatched when a WHOIS query is completed
class WhoisEvent extends Event {
  WhoisBuilder builder;

  WhoisEvent(Client client, this.builder) : super(client);

  /// The Channels the user is a member in
  List<String> get memberChannels {
    var list = <String>[];
    list.addAll(builder.channels.where((i) =>
        !operatorChannels.contains(i) &&
        !voicedChannels.contains(i) &&
        !ownerChannels.contains(i) &&
        !halfOpChannels.contains(i)));
    return list;
  }

  /// The Channels the user is an operator in
  List<String> get operatorChannels => builder.opIn;

  /// The Channels the user is a voice in
  List<String> get voicedChannels => builder.voiceIn;

  List<String> get ownerChannels => builder.ownerIn;
  List<String> get halfOpChannels => builder.halfOpIn;

  /// If the user is away
  bool get away => builder.away;

  /// If the user is away
  bool get isAway => away;

  /// If the user is away, then this is the message that was set
  String get awayMessage => builder.awayMessage;

  /// If this user is a server operator
  bool get isServerOperator => builder.isServerOperator;

  /// The name of the server this user is on
  String get serverName => builder.serverName;

  bool get secure => builder.secure;

  /// The Server Information (message) for the server this user is on
  String get serverInfo => builder.serverInfo;

  /// The User's Username
  String get username => builder.username;

  /// The User's Hostname
  String get hostname => builder.hostname;

  /// If the user is idle
  bool get idle => builder.idle;

  /// If the user is idle, then this is the amount of time that the user has been idle
  int get idleTime => builder.idleTime;

  /// The User's Real Name
  String get realname => builder.realName;

  /// The User's Nickname
  String get nickname => builder.nickname;

  @override
  String toString() => builder.toString();
}

class PongEvent extends Event {
  /// Message in the PONG
  String message;

  PongEvent(Client client, this.message) : super(client);
}

/// An Action Event
class ActionEvent extends MessageEvent {
  ActionEvent(Client client, User from, Entity target, String message)
      : super(client, from, target, message);

  /// Sends [message] to [target] as a action.
  @override
  void reply(String message) => client.sendAction(from.name, message);
}

/// A Kick Event
class KickEvent extends Event {
  /// The Channel where the event is from
  Channel channel;

  /// The User who was kicked
  User user;

  /// The User who kicked the other user
  User by;

  /// The Reason Given for [by] kicking [user]
  String reason;

  KickEvent(Client client, this.channel, this.user, this.by, [this.reason])
      : super(client);
}

/// A Client to Client Protocol Event.
/// ActionEvent is executed on this event as well.
class CTCPEvent extends Event {
  /// The User who sent the message
  User user;

  /// The Target of the message
  Entity target;

  /// The Message sent
  String message;

  CTCPEvent(Client client, this.user, this.target, this.message)
      : super(client);
}

/// Server MOTD Recieved
class MOTDEvent extends Event {
  /// MOTD Message
  String message;

  MOTDEvent(Client client, this.message) : super(client);
}

/// Server ISUPPORT Event
class ServerSupportsEvent extends Event {
  /// Supported Stuff
  Map<String, dynamic> supported;

  ServerSupportsEvent(Client client, String message) : super(client) {
    supported = {};
    var split = message.split(" ");
    split.forEach((it) {
      if (it.contains("=")) {
        var keyValue = it.split("=");
        var key = keyValue[0];

        dynamic value = keyValue[1];
        var numeric = num.tryParse(value);
        if (numeric != null) {
          value = numeric;
        }
        supported[key] = value;
      } else {
        supported[it] = true;
      }
    });
  }
}

/// Invite Event
class InviteEvent extends Event {
  /// The Channel that the client was invited to
  String channel;

  /// The user who invited the client
  String user;

  InviteEvent(Client client, this.channel, this.user) : super(client);

  /// Joins the Channel
  void join() => client.join(channel);

  /// Sends a Message to the User
  void reply(String message) => client.sendMessage(user, message);
}

class UserInvitedEvent extends Event {
  /// The Channel that this invite was issued for.
  Channel channel;

  /// The user who was invited.
  String user;

  /// The user who invited.
  User inviter;

  UserInvitedEvent(Client client, this.channel, this.user, this.inviter)
      : super(client);
}
