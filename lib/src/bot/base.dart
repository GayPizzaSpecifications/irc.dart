part of irc.bot;

/**
 * Base Class for Bots
 */
abstract class Bot {
  /**
   * Gets the Client
   */
  Client get client;

  /**
   * Connects the Bot
   */
  void connect() => client.connect();

  /**
   * Disconnects the Bot
   */
  Future disconnect() => client.disconnect();

  /**
   * Gets a Channel
   */
  Channel getChannel(String name) => client.getChannel(name);

  /**
   * Registers a Handler
   */
  bool register(handler) => client.register(handler);
  
  /**
   * Registers a Handler or Behavior
   */
  bool apply(handler) => register(handler);

  /**
   * Joins a Channel
   */
  void join(String channel) => client.join(channel);

  /**
   * Parts a Channel
   */
  void part(String channel) => client.part(channel);

  /**
   * Sends a Message
   */
  void sendMessage(String target, String message) => client.sendMessage(target, message);
  
  Stream<Event> onEvent(Type type) => client.onEvent(type);
  
  Stream<ConnectEvent> get onConnect => onEvent(ConnectEvent);
  Stream<DisconnectEvent> get onDisconnect => onEvent(DisconnectEvent);
  Stream<MessageEvent> get onMessage => onEvent(MessageEvent);
  Stream<BotJoinEvent> get onBotJoin => onEvent(BotJoinEvent);
  Stream<BotPartEvent> get onBotPart => onEvent(BotPartEvent);
  Stream<JoinEvent> get onJoin => onEvent(JoinEvent);
  Stream<PartEvent> get onPart => onEvent(PartEvent);
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
  
  Stream<Event> get events => client.events;
}

typedef void EventHandler<T>(T event);
