part of irc.bot;

/**
 * Base Class for Bots
 */
abstract class Bot {
  Client client();

  void connect() => client().connect();
  void disconnect() => client().disconnect();

  Channel channel(String name) => client().channel(name);

  Stream<Event> on(EventType<Event> type) => client().on(type);

  StreamSubscription<ReadyEvent> whenReady(Function handler) => on(Events.Ready).listen(handler);

  StreamSubscription<JoinEvent> onJoin(Function handler) => on(Events.Join).listen(handler);

  StreamSubscription<PartEvent> onPart(Function handler) => on(Events.Part).listen(handler);

  StreamSubscription<BotJoinEvent> onBotJoin(Function handler) => on(Events.BotJoin).listen(handler);

  StreamSubscription<BotPartEvent> onBotPart(Function handler) => on(Events.BotPart).listen(handler);

  StreamSubscription<LineSentEvent> onLineSent(Function handler) => on(Events.LineSent).listen(handler);

  StreamSubscription<LineReceiveEvent> onLineReceived(Function handler) => on(Events.LineReceive).listen(handler);

  StreamSubscription<MessageEvent> onMessage(Function handler) => on(Events.Message).listen(handler);

  StreamSubscription<ConnectEvent> onConnect(Function handler) => on(Events.Connect).listen(handler);

  StreamSubscription<DisconnectEvent> onDisconnect(Function handler) => on(Events.Disconnect).listen(handler);

  void join(String channel) => client().join(channel);

  void part(String channel) => client().part(channel);

  void message(String target, String message) => client().message(target, message);
}