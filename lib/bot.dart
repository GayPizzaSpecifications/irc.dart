/* Bot Abstraction */
part of irc;

/**
 * Base Class for Bots
 */
abstract class Bot {
    void connect() => client().connect();
    void disconnect() => client().disconnect();

    Client client();

    Stream<Event> on(EventType<Event> type) => client().on(type);

    StreamSubscription<ReadyEvent> whenReady(Function handler) {
        return on(Events.Ready).listen(handler);
    }

    StreamSubscription<JoinEvent> onJoin(Function handler) {
        return on(Events.Join).listen(handler);
    }

    StreamSubscription<MessageEvent> onMessage(Function handler) {
        return on(Events.Message).listen(handler);
    }

    StreamSubscription<ConnectEvent> onConnect(Function handler) {
        return on(Events.Connect).listen(handler);
    }

    void join(String channel) {
        client().join(channel);
    }
}