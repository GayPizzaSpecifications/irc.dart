part of irc;

class EventEmitting {
    EventBus _eventBus = new EventBus();

    void fire(EventType type, data) {
        _eventBus.fire(type, data);
    }

    Stream on(EventType type) {
        return _eventBus.on(type);
    }
}

class Events {
    static final EventType<ConnectEvent> Connect = new EventType<ConnectEvent>();
    static final EventType<ReadyEvent> Ready = new EventType<ReadyEvent>();
    static final EventType<LineEvent> Line = new EventType<LineEvent>();
    static final EventType<SendEvent> Send = new EventType<SendEvent>();
    static final EventType<JoinEvent> Join = new EventType<JoinEvent>();
    static final EventType<MessageEvent> Message = new EventType<MessageEvent>();
}

abstract class Event {
    IRCClient client;
}

class ConnectEvent extends Event {
    ConnectEvent(IRCClient client) {
        this.client = client;
    }
}

class ReadyEvent extends Event {
    ReadyEvent(IRCClient client) {
        this.client = client;
    }

    void join(String channel) {
        client.join(channel);
    }
}

class LineEvent extends Event {
    String command;
    String prefix;
    List<String> params;
    IRCParser.Message message;

    LineEvent(IRCClient client, this.command, this.prefix, this.params, this.message) {
        this.client = client;
    }
}

class MessageEvent extends Event {
    String from;
    String target;
    String message;

    MessageEvent(IRCClient client, this.from, this.target, this.message) {
        this.client = client;
    }

    Channel channel() {
        return client.channel(target);
    }

    void reply(String message) {
        client.message(target, message);
    }
}

class JoinEvent extends Event {
    Channel channel;
    String user;

    JoinEvent(IRCClient client, this.user, this.channel) {
        this.client = client;
    }

    void reply(String message) {
        channel.message(message);
    }

    bool isBot() {
        return user == client.config.nickname;
    }
}

class SendEvent extends Event {
    String line;

    SendEvent(IRCClient client, this.line) {
        this.client = client;
    }
}