/* Bot Abstraction */
library irc.bot;

import "package:irc/irc.dart";
import "dart:async";

part "dumbbot.dart";
part "commandbot.dart";

/**
 * Base Class for Bots
 */
abstract class Bot {

    void connect() => client().connect();

    void disconnect() => client().disconnect();

    Client client();

    Stream<Event> on(EventType<Event> type) => client().on(type);

    StreamSubscription<ReadyEvent> whenReady(Function handler) =>
        on(Events.Ready).listen(handler);

    StreamSubscription<JoinEvent> onJoin(Function handler) =>
        on(Events.Join).listen(handler);

    StreamSubscription<MessageEvent> onMessage(Function handler) =>
        on(Events.Message).listen(handler);

    StreamSubscription<ConnectEvent> onConnect(Function handler) =>
        on(Events.Connect).listen(handler);

    void join(String channel) =>
        client().join(channel);
}
